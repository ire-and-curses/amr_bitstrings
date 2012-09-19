#!/usr/bin/perl

# run_amr.pl - Demonstrate nearest neighbour and radius calculations on an AMR
#              grid using a novel bistring representation.
# Version 1.0
# Eric Saunders, June 2008



use strict;
use warnings;

use AMR       qw(:all);
use AMR::Test qw(:all);

use Getopt::Long;
use Data::Dumper;

use GD::Simple;


my $version = '1.0';

# Set up command line options...
my %opts;
GetOptions(
             'grid=s'             => \$opts{grid_type },
             'ncells=i'           => \$opts{ncells    },
             'outfile|file|png=s' => \$opts{outfile   },
             'lr=s'               => \$opts{lr        },
             'ud=s'               => \$opts{ud        },
             'verbose+'           => \$opts{verbose   },
             'radius=f'           => \$opts{radius    },
             'neighbours'         => \$opts{neighbours},
             'help'               => \$opts{help      },
           );

# Print an informative header...
print "   $0 - Demonstrate nearest neighbour and radius calculations on\n"
    . "                an AMR grid using a novel bitstring representation.\n\n"
    . "   Version $version, June 2008\n"
    . "   Eric Saunders (esaunders\@lcogt.net)\n\n";


# Print some help if specified on the command line...
usage() if ( $opts{help} );

# Validate the grid type...
handle_grid_option(\%opts);

# Generate the grid...
my ($max_gen, @cells) = get_grid($opts{grid_type});

# Print some status info about the grid...
verbalise(scalar @cells . " cells generated.\n", 1);
verbalise("The maximum generation for a cell in this grid is $max_gen.\n", 2);
verbalise("Cell dump of all grid cells:\n", 2);
if ( defined $opts{verbose} && $opts{verbose} >=2 ) {
   foreach my $cell ( @cells ) {
      my @current_cells = ref($cell) eq 'ARRAY' ? @{$cell} : ($cell);
      print_cell($_) for (@current_cells);
   }
}


# Convert the grid into corner coordinates...
my @coords = find_all_cell_corners(@cells);

# Draw the grid...
my $img = GD::Simple->new(700,700);
$img->fgcolor('black');
draw_cells('white', @coords);

# Print out all the coordinates...
verbalise("Cell corner coordinates for all grid cells:\n",2);
if ( defined $opts{verbose} && $opts{verbose} >= 2 ) {
   print Dumper @coords;
}


# Validate the user-supplied bitstrings for the target cell...
handle_cell_bitstrings_option(\%opts);

# Convert the user strings to actual bitstrings...
my $x_bs = string_to_bitstring($opts{lr});
my $y_bs = string_to_bitstring($opts{ud});

# Find the target cell corresponding to the provided bitstrings...
my $target_cell     = find_matching_cell($x_bs, $y_bs, $max_gen, @cells);

verbalise("Target cell has id $target_cell->{id}, "
          . "and will be coloured in green.\n",1);


# Crawl the grid and construct a neighbour list...
my $edges = build_neighbour_list($target_cell, $max_gen, @cells);

# Print out all the edge relationships...
verbalise("Edges: \n",2);
if ( defined $opts{verbose} && $opts{verbose} >= 2 ) {
   foreach my $edge ( @{$edges} ) {
      print "$edge->[0]->{id} <-> $edge->[1]->{id}\n";
   }
}


# Check if the user wants a radius calculation, and validate if so...
handle_radius_option(\%opts);

# Calculate all cells falling within the radius...
if ( $opts{radius} ) {
   my $enclosed_cells = get_all_cells_within_radius($target_cell, $opts{radius},
                                                    $edges);

   my @enclosed_coords = find_all_cell_corners($enclosed_cells);
   draw_cells('blue', @enclosed_coords);
}

# Check if the user wants neighbours to be displayed...
handle_neighbours_option(\%opts);

# Find them if so...
if ( $opts{neighbours} ) {
   my $neighbours = get_cell_neighbours($target_cell, $edges);

   # Dump some neighbour information...
   verbalise("Neighbours: \n",1);
   if ( defined $opts{verbose} ) {
      if ( $opts{verbose} >= 2 ) {
         print_cell($_) for @{$neighbours};
      }
      elsif ($opts{verbose} == 1 ) {
         print "$_->{id}\n" for @{$neighbours};
      }
   }

   # Colour in the neighbours...
   my @neighbour_coords = find_all_cell_corners($neighbours);
   draw_cells('cyan', @neighbour_coords);

}


# Draw the target cell...
my ($target_coords) = find_all_cell_corners($target_cell);
draw_cells('green', ($target_coords));

# Add a title...
draw_title(scalar(@cells));

# Check they actually wanted an image of the grid...
handle_outfile_option(\%opts);

# Write the grid to file if they did...
write_grid_to_file($opts{outfile}) if $opts{outfile};






sub handle_grid_option {
   my $opts = shift;

   my @valid_grid_options = qw( test test2 random );

   if ( defined $opts{grid_type} ) {
      my $regex = join('|', @valid_grid_options);
      $opts{grid_type} = undef unless $opts{grid_type} =~ m/$regex/i;
   }


   unless ( defined $opts{grid_type} ) {
      my $choice;

      for ( 1..1 ) {
         my $default = 3;

         print "Select grid type:\n";
         print "   1) Test grid\n";
         print "   2) Alternate test grid\n";
         print "   3) Random grid (default)\n";
         print "=> ";
         chomp($choice = <>);

         $choice = $default if $choice =~ m/^$/;
         redo unless $choice =~ m/[123]/;
      }

      $opts{grid_type} = $valid_grid_options[$choice-1];
   }

   verbalise("Grid type is '$opts{grid_type}'.\n",1);

   return;
}


sub handle_ncells_option {
   my $opts = shift;

   if ( defined $opts{ncells} ) {
      $opts{ncells} = undef unless $opts{ncells} =~ m/\d+/;
   }

   unless ( defined $opts{ncells} ) {
      my $choice;

      for ( 1..1 ) {
         my $default = 30;
         print "Maximum number of cells to generate [$default]: ";
         chomp($choice = <>);

         $choice = $default if $choice =~ m/^$/;
         redo unless $choice =~ m/\d+/;

         $choice = 4   if ( $choice < 4   );
         $choice = 500 if ( $choice > 500 );
      }
      $opts{ncells} = $choice;
   }

   verbalise("Ncells = $opts{ncells}.\n",1);

   return;
}


sub handle_cell_bitstrings_option {
   my $opts = shift;


   my %bitrep = ('lr' => '01', 'ud' => '10');
   foreach my $dim ( sort keys %bitrep ) {

      if ( defined $opts{$dim} ) {
         $opts{$dim} = undef unless (  $opts{$dim} =~ m/[$dim$opts{$dim}]+/i
                                    && length($opts{$dim}) <= 8 );
      }

      unless ( defined $opts{$dim} ) {
         my $choice;
         for ( 1..1 ) {

            print "Enter the $dim bitstring of the cell you wish to select. \n"
                . "This may be up to 8 elements. You may use either \n"
                . "symbolic ($dim) or numeric ($bitrep{$dim}) notation "
                . "[00000000]: ";
            chomp($choice = <>);
            $choice = '00000000' if $choice =~ m/^$/;
            redo unless (    $choice =~ m/[$dim$bitrep{$dim}]+/i
                          && length($choice) <= 8 );
         }

         $opts{$dim} = $choice;
      }
   }

   $opts{lr} =~ tr/lrLR/0101/;
   $opts{ud} =~ tr/udUD/1010/;

   verbalise("lr string of target cell is '$opts{lr}'.\n",2);
   verbalise("ud string of target cell is '$opts{ud}'.\n",2);

   return;
}


sub handle_outfile_option {
   my $opts = shift;

   unless ( defined $opts{outfile} ) {
      my $choice;

      return unless yes_or_no('Output 2D representation to file?');

      my $default = 'grid.png';
      print "File to write [$default]: ";
      chomp($choice = <>);

      $choice = $default if $choice =~ m/^$/;

      $opts{outfile} = $choice;
   }

   return;
}


sub handle_neighbours_option {
   my $opts = shift;

   unless ( defined $opts{neighbours} ) {
      $opts{neighbours} = yes_or_no('Identify nearest neighbours?');
   }

   return;
}


sub handle_radius_option {
   my $opts = shift;

   unless ( defined $opts{radius} ) {
      my $choice;

      return unless yes_or_no('Find all cells within a given radius?');

      for (1..1) {
         my $default = 0.3;
         print "Enter radius, as a fraction of the total grid length "
             . "[$default]: ";
         chomp($choice = <>);

         $choice = $default if $choice =~ m/^$/;

         redo unless $choice =~ m/[.\d]+/;
      }

      $opts{radius} = $choice;

   }

   return;
}


sub yes_or_no {
   my $question = shift;

   print "$question (y/n) [y] ";
   chomp(my $choice = <>);

   return 0 if ( $choice =~ m/^n/i );
   return 1;
}


sub get_grid {
   my $opts = shift;

   my @cells;
   my $max_gen;
   if ( $opts{grid_type} eq 'test' ) {
      @cells = get_first_test_grid();
      $max_gen = 3;
   }
   elsif ( $opts{grid_type} eq 'test2' ) {
      @cells = get_second_test_grid();
      $max_gen = 2;
   }
   elsif ($opts{grid_type} eq 'random' ) {
      handle_ncells_option(\%opts);
      my $cells_ref;
      ($cells_ref, $max_gen) = build_random_grid($opts{ncells});
      @cells = @{$cells_ref};
   }

   return ($max_gen, @cells);
}


sub string_to_bitstring {
   my $string = shift;

   my $bs = '';

   for my $idx ( 0..length($string)-1 ) {
      vec($bs, $idx, 1) = substr($string,$idx,1);
   }

   return $bs;
}


sub draw_cells {
   my $cell_colour = shift;
   my @coords = @_;

   $img->bgcolor($cell_colour);
   foreach my $coord_pair ( @coords ) {
      $img->rectangle(@{$coord_pair});
   }
}

sub draw_title {
   my $ncells = shift;

   $img->moveTo(140,25);
   $img->font('Arial');
   $img->fontsize(18);
   $img->string("AMR grid, $ncells cells");

   return;
}


sub write_grid_to_file {
   my $outfile = shift;

   open my $img_fh, '>', $opts{outfile}
      or die "Couldn't open $opts{outfile} to write: $!";
   print $img_fh $img->png;
   close $img_fh;

   verbalise("Grid written to $opts{outfile}.\n",1);

   return;
}

sub usage {
   die
       "   Options:\n"
     . "       --grid=[test|test2|random]  select grid\n"
     . "       --ncells=NUMBER             maximum number of cells\n"
     . "       --outfile=OUTFILE           filename for writing png\n"
     . "       --lr=BITSTRING              symbols or numbers\n"
     . "       --ud=BITSTRING              up to 8 character encoding\n"
     . "       --verbose                   print extra logging info\n"
     . "       --radius=NUMBER             search radius as fraction of grid\n"
     . "       --neighbours                highlight immediate neighbours\n"
     . "       --help                      print this message and exit\n"


     . "\nExample usage: perl $0 --grid=random --ncells=120 --verbose"
     . " --lr=lrl --ud=01010 --neighbours --radius=0.3 --outfile=grid.png\n";
}



sub verbalise {
   my $verbosity_level = pop;
   print @_ if ( defined $opts{verbose} && $opts{verbose} >= $verbosity_level);
}

sub print_vec_dec {
   print bintodec(unpack("b*", $_[0]));
}

sub bintodec {
  unpack("N", pack("b32", substr("0" x 32 . shift, -32)));
}


=head1 AUTHOR

Eric Saunders E<lt>eric.saunders@gmail.comE<gt>

=cut


=head1 LICENCE AND COPYRIGHT

Copyright 2008 Eric Saunders

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
