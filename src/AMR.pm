package AMR;

=head1 NAME

AMR - Bitstring implementation of a 2D square adaptive mesh.

=cut

=head1 VERSION 1.0

Eric Saunders, June 2008


=head1 DESCRIPTION

This module implements a 2D square adaptive mesh. Each cell of the mesh is fully
specified using a custom binary notation, which also stores the full ancestory
of each cell. The binary encoding is implemented using bitstrings, which allow
for extremely dense packing of data. The mesh representation can be efficiently
traversed to generate a list of the immediate neighbours of each cell. This is a
graph, where each node is a cell, and each edge between nodes indicates a
neighbour relationship.

=cut


=head1 NAMING SCHEME

Each cell in the grid is assigned a binary name that uniquely defines its
position and size relative to the root cell (the cell with dimensions of the
grid itself) in each dimension. A cell's name is defined recursively, by its
relative position with respect to its immediate ancestor. For example, a cell
must be in either the left or right half of its parent cell, and also in either
the top or bottom half. These four possibilities could be represented
symbolically as

 L D  left-down
 L U  left-up
 R D  right-down
 R U  right-up

Similarly, the parent cell is named relative to its parent. If the leftmost
element of the name represents the first level of refinement (i.e. the
relationship of the first children to the root cell), then the absolute name of
any cell is the recursive chain of parent-child relationships.

Figure 1 demonstrates the naming scheme for a grid of 12 cells (ignoring the
root cell), with three levels of refinement.


                                                          id=2
                                                  -----|  R  1
     ----------------------- ----------- -----------   |  U  1
    |                       |           |           |  |
    |                       |   id=5    |   id=6    |
    |         id=1          |           |           |
    |                       |   RL 10   |  RR 11    |
    |                       |   UU 11   |  UU 11    |
    |         L  0           ----- ----- -----------
    |         U  1          |  9  | 10  |           |     id 7  RL 10
    |                       |     |     |  id=8     |     |     UD 10
    |                        ----- -----            |     |
    |                       | 11  | 12  |  RR 11    |     |---id 9  RLL 100
    |                       |     |     |  UD 10    |     |         UDU 101
     ----------------------- ----- ----- -----------|     |
    |                       |                       |     |--id 10  RLR 101
    |                       |                       |     |         UDU 101
    |         id=3          |         id=4          |     |
    |                       |                       |     |--id 11  RLL 100
    |         L  0          |         R  1          |     |         UDD 100
    |         D  0          |         D  0          |     |
    |                       |                       |     |--id 12  RLR 101
    |                       |                       |               UDD 100
    |                       |                       |
    |                       |                       |
    |                       |                       |
     ----------------------- -----------------------

     Figure 1   AMR grid: 12 cells, 3 generations.

For example, cell 9 is called 'RLL UDU'. This can be read as "In the right-up
corner of the root cell, then in the left-down corner of that cell, then in the
left-up corner of that cell". A cell's level of refinement is called its
'generation'. Cell 9 has a generation of 3. It is apparent that the generation
of  a cell is equal to the length of that cell's name in each dimension.

The efficiency of the naming scheme is made possible by the very restricted
geometry of the grid, where all cells are square, and symmetric quadrisection is
the only method of cell refinement.

If we define the name according to a convention that tells us where each
dimension begins and ends, and define a positive direction in each dimension,
then we can replace the symbolic 'LRUD' with true binary, with no loss of
information.

For example, for cell 9

If L=0, R=1 and D=0, U=1, then

 RLL => 100
 UDU => 101

=cut


=head1 PROPERTIES OF THE BINARY SPACE

The binary space thus defined has some particularly useful properties.

=over

=item 1.

B<It is quantised.> The complete set of all allowed positions in each dimension
of a 3rd generation grid is

 0                 1
 00       01       10       11
 000 001  010 011  100  101 110 111

Ordering these gives

(0, 00, 000, 001, 01, 010, 011 , 1, 10, 100, 101, 11, 110, 111)

No other positions are possible. This means that if the generation of the grid
is known then certain facts, such as the identity of the smallest next possible
cell, can be deduced by an algorithm without the need for any brute force
searching. Another example arising from the symmetric bisection in each
dimension is that if the existence of cell 10 is known, then the existence of
cell 11 can be deduced. This is the same as saying 'if cell 1 has children,
there must be exactly two of them, and they must be called 10 and 11'.


=item 2.

B<It allows distances to be calculated.>

If we assume the convention that the cell position refers to the position of
the most negative corner (i.e. left-bottom in 2D), then

 0 == 00 == 000

all specify the same x point (the left-edge of a 2D grid). Note that

 1 == 10 == 100

specifies the centre of the x dimension, and that the highest allowed value,
111, specifies the left hand edge of the smallest right-most cell.

This convention effectively shrinks the grid of Figure 1 to the following set
of points:





                               5           6
   11-.     .     .     .     X     .     X     .
      |
      |                        9     10
  101-.     .     .     .     X     X     .     .
      |
      |1                     2,7,11  12    8
    1-X     .     .     .     X     X     X     .
      |
      |
  011-.     .     .     .     .     .     .     .
      |
      |
   01-.     .     .     .     .     .     .     .
      |
      |
  001-.     .     .     .     .     .     .     .
      |
      |3                       4
    0-X-----.-----.-----.-----X-----.-----.-----.
      |     |     |     |     |     |     |     |
      0     001   01    011   1     101   11    111


     Figure 2   AMR grid, after shrinking to corners. '.' indicates
     an allowed quantisation. 'x' indicates the presence of a cell.


As Figure 2 shows, the corner convention preserves the distances between cells.
This means that distances can be calculated using simple binary subtraction.

Note that there is still no loss of information, since the cell walls can be
reconstructed if their generations are known.

=back


=head1 IMPLEMENTATION

=head2 BITSTRING AND CELL REPRESENTATION

The encoding scheme is implemented in this module using bitstrings (sometimes
called bit vectors). A bitstring uses each bit as a flag to allow the efficient
storage and manipulation of boolean values. A single byte of memory allows the
storage of an 8th generation cell position in one dimension.

In this implementation, the most significant bit is leftmost (as with standard
numbers). Bitstrings have been implemented using vec(), which always allocates 8
bits at a time. For this reason, the generation must be stored seperately. It is
possible to implement the bitstrings directly using pack() and unpack(), which
would allow fine grained control of length. This is significantly lower level
however, so is beyond the scope of this prototype.

For convenience, a cell structure is defined. In a truly memory-intensive code,
much of this could be dispensed with. Cells in this module look like this:

 $cell = {
           id          => 1,
           lr          => '',
           ud          => '',
           gen         => '',
           is_a_parent => ''
         }


=head2 EFFICIENT GRID TRAVERSAL AND NEAREST NEIGHBOUR LOOKUPS

The crawl_grid() function efficiently traverses the grid by deducing cell jumps,
and uses recursion in each both directions of each dimension to guarantee a full
traversal. It can be used to generate a list of neighbours for every cell, which
can be stored at the same time the grid is generated. Although cell structures
are used here, if size is an issue, the list could be efficiently stored using
bitstrings alone. The existence of such a list makes nearest neighbour lookups
and radius inclusion tests trivial.


=head2 UNIT TESTS

Many of the results of functions in this module are not trivially verifiable.
The module comes with a comprehensive suite of unit tests (amr.t), which may be
run from the command line by

$ perl amr.t

to check function correctness.


=head2 DEMONSTRATION CODE

The supplied run_amr.pl code demonstrates the use of the module. It may be run
interactively or fully specified by command line flags (try --help for options).
The CPAN module GD::Simple is required to display output.


=cut


use strict;
use warnings;

require Exporter;
use vars qw( $VERSION @EXPORT_OK %EXPORT_TAGS @ISA );

@ISA = qw( Exporter );
@EXPORT_OK = qw(
                  build_neighbour_list
                  crawl_grid
                  build_random_grid
                  quadrisect_grid
                  get_next_cell
                  find_next_cell_bitstring
                  find_matching_cell
                  bitstrings_match
                  subtract_bitstrings
                  incr_bitstring
                  compare_bitstrings
                  get_all_cells_within_radius
                  cell_is_within_radius
                  length_to_bitstring
                  cell_is_in_list
                  get_cell_neighbours
                  deduce_siblings
                  grep_siblings
                  find_all_cell_corners
                  find_cell_corners
                  find_cell_centre
                  get_cell_0
                  print_cell
                  print_vector
                  toggle_debugging
                );

%EXPORT_TAGS = (
                  'all' => [ qw(
                                 build_neighbour_list
                                 crawl_grid
                                 build_random_grid
                                 quadrisect_grid
                                 get_next_cell
                                 find_next_cell_bitstring
                                 find_matching_cell
                                 bitstrings_match
                                 subtract_bitstrings
                                 incr_bitstring
                                 compare_bitstrings
                                 get_all_cells_within_radius
                                 cell_is_within_radius
                                 length_to_bitstring
                                 cell_is_in_list
                                 get_cell_neighbours
                                 deduce_siblings
                                 grep_siblings
                                 find_all_cell_corners
                                 find_cell_corners
                                 find_cell_centre
                                 get_cell_0
                                 print_cell
                                 print_vector
                                 toggle_debugging
                               )
                           ],
                 );


=head1 EXPORTED ROUTINES

=over


=item B<build_neighbour_list>

Given a starting cell, the maximum generation a cell in the grid can be, and a
list of cells to crawl, returns the complete list of edges (links between
neighbours).

$edge_list = build_neighbour_list($current_cell, $max_gen, @cells_to_crawl);

$edge_list = [
               [cell1, cell2],
               [cell3, cell4],
               ...
             ]

=cut
sub build_neighbour_list {
   my $current_cell = shift;
   my $max_gen      = shift;

   my @cells_to_search = @_;

   my $inclusion_fn = sub { !edge_is_in_list(@_) };

   return crawl_grid($current_cell, $max_gen, [], $inclusion_fn,
                     @cells_to_search);
}


=item B<crawl_grid>

Given a starting cell, the maximum generation a cell in the grid can be, an
inclusion function that tests for some condition, and a list of cells to crawl,
returns the complete list of cells that pass the test.


$member_list = crawl_grid($current_cell, $max_gen, [], $inclusion_fn,
                          @cells_to_crawl);

$edge_list = [
               [cell1, cell2],
               [cell3, cell4],
               ...
             ]

=cut
sub crawl_grid {
   my $current_cell   = shift;
   my $max_gen        = shift;
   my $passed_so_far  = shift;
   my $inclusion_fn   = shift;

   my @cells_to_search = @_;


   debug("\n\n***RECURSED*** Current cell id is $current_cell->{id}.\n");
   debug("Max gen = $max_gen");

   # Right, up, left, down - the grid will be crawled in this order...
   my @directions = qw( r u l d);

   # Cycle through the directions...
   foreach my $dir ( @directions ) {

      # Get the next cell in this direction...
      my $next_cell = get_next_cell($current_cell, $dir, $max_gen,
                                    @cells_to_search);

      # If we have a cell, we've not reached the extreme edge in this dir yet...
      if ( $next_cell ) {

         # Move on if this element doesn't pass the supplied test...
         next unless $inclusion_fn->([$current_cell, $next_cell],
                                     $passed_so_far);


         # If it does, add the element to our list of elements...
         debug("Adding edge: [$current_cell->{id}, $next_cell->{id}]");
         push @{$passed_so_far}, [$current_cell, $next_cell];

         # ...and continue recursing in this direction...
         $passed_so_far  = crawl_grid($next_cell, $max_gen, $passed_so_far,
                                      $inclusion_fn, @cells_to_search);

      }
   }


   # All directions have been exhausted - return our stash of recursed edges...
   return $passed_so_far;
}


=item B<build_random_grid>

Given a cell limit, the maximum allowed generation of a cell, and a starting id
number and initial cell, returns a random quadrisected grid. Until the cell
limit is reached, cells are chosen at random and quadrisected. The final set of
cells and the maximum generation attained are returned.

($cell_list, $highest_gen) = build_random_grid($max_cells, $max_gen,
                                               $starting_id, $initial_cell);

$cell_list = [$cell_1, $cell_2, ...]

=cut

sub build_random_grid {
   my $max_cells = shift;

   my $starting_gen = 0;
   my $starting_id = 0;

   my ($cells, $max_gen) = quadrisect_grid($max_cells, $starting_gen,
                                           $starting_id, get_cell_0());

   # Throw away the root cell, cell id 0...
   shift @{$cells};

   return ($cells, $max_gen);
}


sub quadrisect_grid {
   my $max_cells       = shift;
   my $max_gen_so_far  = shift;
   my $current_cell_id = shift;

   my @cells = @_;


   # Termination condition - return when we have enough cells...
   return (\@cells, $max_gen_so_far) if ( @cells > ( $max_cells-4 ) );

   # Randomly choose a previously unsplit cell to split...
   my $parent;
   for (1..1) {
      $parent = $cells[int(rand(@cells))];
      redo if defined $parent->{is_a_parent};
   }

   # Set the parent flag so this cell is not chosen again...
   $parent->{is_a_parent} = 1;

   # Track the highest generation produced so far...
   my $new_gen = $parent->{gen} + 1;
   $max_gen_so_far = $new_gen if $new_gen > $max_gen_so_far;


   # Initialise the set of subcells...
   my @subcells;
   for ( 1..4 ) {
      push @subcells,
                     {
                        lr =>  $parent->{lr},
                        ud =>  $parent->{ud},
                        gen => $new_gen,
                        id  => ++$current_cell_id,
                     };
   }

   # Uniquely define each subcell by setting the least significant bit...
   #  ----- -----
   # | l,u | r,u |
   # | 0,1 | 1,1 |
   #  ----- -----
   # | l,d | r,d |
   # | 0,0 | 1,0 |
   #  ----- -----

   # Set left-up...
   vec($subcells[0]->{lr},$new_gen-1,1) = 0;
   vec($subcells[0]->{ud},$new_gen-1,1) = 1;

   # Set right-up...
   vec($subcells[1]->{lr},$new_gen-1,1) = 1;
   vec($subcells[1]->{ud},$new_gen-1,1) = 1;

   # Set left-down...
   vec($subcells[2]->{lr},$new_gen-1,1) = 0;
   vec($subcells[2]->{ud},$new_gen-1,1) = 0;

   # Set right-down...
   vec($subcells[3]->{lr},$new_gen-1,1) = 1;
   vec($subcells[3]->{ud},$new_gen-1,1) = 0;

   # Add the subcells to the cell list...
   @cells = (@cells, @subcells);

   # Recurse...
   return quadrisect_grid($max_cells, $max_gen_so_far, $current_cell_id, @cells);
}


=item B<get_next_cell>

Given a starting cell, a direction to move in, the maximum generation of a
cell on the grid, and a list of cells to search, returns the next cell in that
direction. If there is no next cell, you've reached the edge of the grid, and
undef is returned.

$next_cell = get_next_cell($current_cell, $direction, $max_gen,
                           @cells_to_search);

=cut
sub get_next_cell {
   my $current_cell    = shift;
   my $dir             = shift;        # 'l' or 'r' or 'u' or 'd'
   my $max_gen         = shift;

   my @cells_to_search = @_;


   debug("Current cell is: $current_cell->{id}");

   # The generation to use for incrementing depends on direction. The numbering
   # scheme refers to the bottom-left corner, so there is an asymmetry - moving
   # in a positive direction (up or right) implies traversing the current cell,
   # whereas moving in a negative direction to find a cell implies moving the
   # minimum distance out of the current cell.
   my $gen;
   $gen = $current_cell->{gen} if ( $dir =~ m/[ru]/ );
   $gen = $max_gen             if ( $dir =~ m/[ld]/ );

   my ($next_cell_bs_lr, $next_cell_bs_ud);

   # If we want the next cell in the lr dimension...
   if ( $dir =~ m/[lr]/ ) {

      # Then calculate the bitstring of the next cell in the lr dimension...
      $next_cell_bs_lr = find_next_cell_bitstring($current_cell->{lr}, $dir,
                                                  $gen);

      # And keep the ud value constant...
      $next_cell_bs_ud = $current_cell->{ud};
   }
   # ...otherwise, we want the next cell in the ud dimension...
   else {
      # Calculate the bitstring of the next cell in the ud dimension...
      $next_cell_bs_ud = find_next_cell_bitstring($current_cell->{ud}, $dir,
                                                  $gen);

      # And keep the lr value constant...
      $next_cell_bs_lr = $current_cell->{lr};
   }


   # Find the smallest parent cell encompassing that bitstring...
   my $next_cell = find_matching_cell($next_cell_bs_lr, $next_cell_bs_ud,
                                      $max_gen, @cells_to_search);

   debug("Next cell found to jump to is $next_cell->{id}");

   # Return undef if we found ourselves, indicating we've reached the end...
   return undef
      if (
           bitstrings_match($current_cell->{lr}, $next_cell->{lr}, $max_gen)
        && bitstrings_match($current_cell->{ud}, $next_cell->{ud}, $max_gen)
        && ( $current_cell->{gen} == $next_cell->{gen} ) );

   # Otherwise, return the next cell...
   return $next_cell;
}


=item B<find_next_cell_bitstring>

Given the bitstring of the current cell in the relevant dimension, the direction
of travel, and the generation to jump to, returns the bitstring corresponding to
the next pertinent cell in this direction. The generation provided must be the
maximum if the direction is negative (l,d), or the current generation of the
cell otherwise. Note also that the return value is a calculation, not a lookup.

$next_bs = find_next_cell_bitstring($current_bs, $dir, $generation);

=cut
sub find_next_cell_bitstring {
   my $current_cell_bs = shift;
   my $dir             = shift;
   my $current_gen     = shift;

   # If the direction is positive...
   return
      incr_bitstring($current_cell_bs, $current_gen) if ( $dir =~ m/[ur+]/ );

   # If the direction is negative...
   if ( $dir =~ m/[dl-]/ ) {
      # Set the minimum offset. NOTE: this should be the max_gen of the grid.
      my $min_bs = '';
      vec($min_bs,$current_gen-1,1) = 1;

      debug("current gen is $current_gen");

      return subtract_bitstrings($current_cell_bs, $min_bs, $current_gen);
   }

   # We shouldn't ever get here...
   die("Invalid direction passed to find_next_cell_bitstring - should be one of"
         . "[ur+dl-]");
}


=item B<find_matching_cell>

Given two bitstrings and a generation to specify a target cell, and a list of
cells to search, returns the exact cell, if it exists, or if not, the nearest
matching parent cell.

$matching_cell = find_matching_cell($x_bs, $y_bs, $target_gen,
                                    @cells_to_search);

=cut
sub find_matching_cell {
   my $x_bs       = shift;
   my $y_bs       = shift;
   my $target_gen = shift;   # The length of the provided bitstrings...

   debug_vector("x_bs = ", $x_bs);
   debug_vector("y_bs = ", $y_bs);
   debug("target generation = $target_gen");

   # Initialise the storage for our matching cell...
   my $best_cell_so_far = {
                            id  => undef,
                            gen => 0,
                           };

   # Initialise the match metric to some arbitrarily huge negative value...
   my $best_metric_so_far = -100000;

   while ( @_ ) {
      my $next_to_process = shift;

      # Expand the array if it's a reference, otherwise store the single value..
      my @cells = ref($next_to_process) eq 'ARRAY' ? @{$next_to_process}
                                                   : ($next_to_process);

      # Chomp through the cells...
      foreach my $cell ( @cells ) {
         # Return immediately if we find the exact cell...
         return $cell
            if (    bitstrings_match($cell->{lr}, $x_bs, $target_gen)
                 && bitstrings_match($cell->{ud}, $y_bs, $target_gen)
                 && $cell->{gen} == $target_gen );

         # Otherwise, track how close we are and keep the best one...
         my $x_bitcompare = ($cell->{lr} ^ $x_bs);
         my $y_bitcompare = ($cell->{ud} ^ $y_bs);

         # TODO: This algorithm is really a hack - we probably shouldn't look in
         # TODO: two directions. The weighting increases the attraction to
         # TODO: parents rather than near neighbours.
         my $x_similarity = 0;
         my $y_similarity = 0;
         my $weighting = 1;

         # Compare the two bitstrings bit by bit...
         for my $idx ( 0..$cell->{gen}-1 ) {
            $x_similarity++          unless vec($x_bitcompare, $idx, 1);
            $x_similarity -= $weighting  if vec($x_bitcompare, $idx, 1);

            $y_similarity++          unless vec($y_bitcompare, $idx, 1);
            $y_similarity -= $weighting  if vec($y_bitcompare, $idx, 1);
            $weighting++;
         }


         debug("cell id = $cell->{id}");
         debug("x similarity: $x_similarity");
         debug("y similarity: $y_similarity");

         # Calculate the rather arbitrary metric...
         my $metric = ($x_similarity + $y_similarity) / $cell->{gen};
         debug("METRIC:              $metric");

         # Store if better than the current best effort...
         if (     $metric >= $best_metric_so_far
               && $cell->{gen} >= $best_cell_so_far->{gen} ) {

            $best_cell_so_far   = $cell;
            $best_metric_so_far = $metric;
         }


      }

   }

   return $best_cell_so_far;
}



=item B<bitstrings_match>

Returns true if two bitstrings match, or false otherwise. Bitstrings only match
if every bit is identical up to the bit of the highest supplied generation.

$matched_flag = bitstrings_match($bs1, $bs2, $gen);

=cut
sub bitstrings_match {
   my $bs1 = shift;
   my $bs2 = shift;
   my $gen = shift;
   my $gen2 = shift;

   # Use the highest generation provided...
   $gen = $gen2 if ( defined $gen2 && $gen2 > $gen );

   # Give up as soon as a non-match is detected...
   for my $idx (0..$gen-1) {
      return 0 unless ( vec($bs1, $idx, 1) == vec($bs2,$idx,1) );
   }

   return 1;
}


=item B<subtract_bitstrings>

Returns the binary subtraction of two bitstrings.

$result_bs = subtract_bitstrings($bs1, $bs2, $gen);

=cut
sub subtract_bitstrings {
   my $bs1  = shift;
   my $bs2  = shift;
   my $gen  = shift;  # The generation of the longer bitstring

   debug_vector("bs1 = ", $bs1);
   debug_vector("bs2 = ", $bs2);


   # Initialise the result bitstring...
   my $result = '';
   vec($result, 0, 1) = 0;


   # Loop over each digit, least significant first...
   for ( my $idx = $gen-1; $idx>=0; $idx-- ) {
      debug("idx is $idx");
      # If this is the special case (0 - 1) where a carry is required...
      if ( (vec($bs1, $idx, 1) ^ 1)  && ( vec($bs2, $idx, 1) ) ^ 0 ) {

         debug("Entering special carry case...");

         # Set this result digit to 1...
         vec($result, $idx, 1) = 1;

         # Set the carry flag...
         my $carry = 1;

         # While there is a carry flag...
         my $cdx = $idx;
         while ( $carry ) {
            $cdx--;
            debug("Looping: cdx is $cdx...");

            # If no previous digit exists to carry from, give up...
            if ( $cdx < 0 ) {
               debug("Giving up - returning all zeros...");

               # Make sure to reset the return value to zeros...
               $result = '';
               vec($result, 0, 1) = 0;
               return $result;
            }

            # Otherwise, look at the previous digit of the first string...
            if ( vec($bs1, $cdx, 1) ) {
               # If it is 1, set it to 0 and clear the flag...
               vec($bs1, $cdx, 1) = 0;
               $carry = 0;
            }
            else {
               # It is 0 - set it to 1 and continue looping...
               vec($bs1, $cdx, 1) = 1;
            }

         }

      }

      # Otherwise, 1-0 = 1, 1-1=0, 0-0=0...
      else {
         vec($result, $idx, 1) = (vec($bs1, $idx, 1) ^ vec($bs2, $idx, 1));
      }
   }

   debug_vector("result = ", $result);

   return $result;
}


=item B<incr_bitstring>

Increments a bitstring by its least significant digit, carrying if necessary.
This effectively moves one current cell width in the positive direction in
binary space.

$incremented_bs = incr_bitstring($bs, $gen);

=cut
sub incr_bitstring {
   my $next_cell_bs = shift;
   my $current_gen  = shift;

   # Check for the special case where we have all ones, and so can't carry. This
   # implies we are on the far right of the grid with nowhere else to go, so we
   # return the number unchanged to indicate a maximum value.
   my $all_ones = 0;
   for my $idx ( 0..$current_gen-1 ) {
      $all_ones++ if vec($next_cell_bs,$idx,1);
   }
   return $next_cell_bs if ( $all_ones == $current_gen );


   # Check for the case where we have to carry binary digits...
   # Start with the least significant bit...
   my $carry = 0;
   for (my $idx=$current_gen-1; $idx>=0; $idx-- ) {
      debug("In loop: idx is $idx");

      # If the current least significant bit is set...
      if ( vec($next_cell_bs,$idx,1) ) {
         debug("Last significant bit is set - toggling off and setting carry");
         # ...set the carry bit and toggle this bit off...
         $carry = 1;
         vec($next_cell_bs,$idx,1) = 0;
      }
      # If not, and there's an outstanding carry bit...
      elsif ( $carry ) {
         debug("Applying outstanding carry bit");

         # ...set this bit...
         vec($next_cell_bs,$idx,1) = 1;

         # ...and get out of here...
         return $next_cell_bs;
      }
      else {
         # The bit wasn't set, so just toggle it on and exit...

         debug("Least significant bit not set - toggling on\n");

         vec($next_cell_bs,$idx,1) = 1;
         return $next_cell_bs;
      }
   }
}



=item B<compare_bitstrings>

Given two bitstrings and a generation (length), returns 1 if 0, or -1, depending
on whether bitstring 1 is bigger, the same, or smaller than bitstring 2.

$comparison = compare_bitstrings($bs1, $bs2, $gen);

=cut
sub compare_bitstrings {
   my $bs1 = shift;
   my $bs2 = shift;
   my $gen = shift;


   # Loop over each bit in turn, most significant first...
   for my $idx (0..$gen-1) {
      # Move to the next digit if these are identical...
      next if vec($bs1, $idx, 1) == vec($bs2, $idx, 1);

      # Return 1 if bitstring 1 is bigger...
      return 1 if ( vec($bs1, $idx, 1) > vec($bs2, $idx, 1) );

      # Return -1 if bitstring 0 is bigger...
      return -1 if ( vec($bs2, $idx, 1) > vec($bs1, $idx, 1) );
   }

   # If we get to here, the bitstrings are identical - return 0...
   return 0;
}


=item B<sort_bitstrings>

Version of compare_bitstrings modified for passing to sort(). An eight bit
comparison is assumed.

my @sorted_bitstrings = sort sort_bitstrings(@bitstrings);

=cut
sub sort_bitstrings {
   my $gen = 8;

   # Loop over each bit in turn, most significant first...
   for my $idx (0..$gen-1) {
      # Move to the next digit if these are identical...
      next if vec($a, $idx, 1) == vec($b, $idx, 1);

      # Return 1 if bitstring 1 is bigger...
      return 1 if ( vec($a, $idx, 1) > vec($b, $idx, 1) );

      # Return -1 if bitstring 0 is bigger...
      return -1 if ( vec($b, $idx, 1) > vec($a, $idx, 1) );
   }

   # If we get to here, the bitstrings are identical - return 0...
   return 0;
}


=item B<get_cell_neighbours>

Given a target cell and a list of neighbour relationships (edges), returns the
other end of each edge containing the target cell, i.e. returns a flat list of
neighbours of the target cell.

$neighbours_list = get_cell_neighbours($target_cell, $edge_list);

$neighbours_list = [ $cell_1, $cell_2, ...];

=cut
sub get_cell_neighbours {
   my $this_cell = shift;
   my $edges     = shift;

   my @neighbours;

   # Examine each edge in turn...
   foreach my $edge ( @{$edges} ) {

      # If the first cell in the edge matches...
      if ( $edge->[0]->{id} eq $this_cell->{id} ) {
         # ...then add the other end to the neighbour list...
         push @neighbours, $edge->[1];
      }
      # Only check the second edge if the first failed...
      elsif ( $edge->[1]->{id} eq $this_cell->{id} ) {
         push @neighbours, $edge->[0];
      }
   }

   return \@neighbours;
}


=item B<get_all_cells_within_radius>

Given a starting cell, a radius expressed as a fraction of the grid  length, and
a list of neighbours, returns all cells whose centres fall within a square box
centred on the starting cell.

$enclosed_cells = get_all_cells_within_radius($this_cell, $radius, $edge_list);

=cut
sub get_all_cells_within_radius {
   my $this_cell = shift;
   my $radius    = shift;
   my $edge_list  = shift;


   # Crawl the neighbour list, accepting anyone who falls within the limits...
   my $neighbours = get_cell_neighbours($this_cell, $edge_list);

   # Initialise the list of valid cells...
   my @enclosed_cells = ($this_cell);

   # Initialise the list of cells we have collected neighbours from...
   my @seen = ($this_cell);

   # As long as there are candidate cells...
   while ( @{$neighbours} ) {
      # Pull a candidate off the stack...
      my $candidate_cell = shift @{$neighbours};

      # If it falls within the square and hasn't yet been seen...
      if (    cell_is_within_radius($radius, $this_cell, $candidate_cell)
           && !cell_is_in_list($candidate_cell, @seen) ) {

         # ...then add the cell to the keep list...
         push @enclosed_cells, $candidate_cell;

         # ...add it to the seen list...
         push @seen, $candidate_cell;

         # ...and add the cell's neighbours to the candidate list...
         @{$neighbours} = (@{$neighbours},
                           @{get_cell_neighbours($candidate_cell, $edge_list)});
      }

   }

   return \@enclosed_cells;
}


=item B<cell_is_within_radius>

Given a starting cell, a radius expressed as a fraction of the grid  length, and
a target cell, returns true if that cell centre falls within the radius, or
false otherwise.

$boolean_flag = cell_is_within_radius($radius, $origin_cell, $target_cell);

=cut
sub cell_is_within_radius {
   my $radius      = shift;    # Radius as a fraction of the grid radius.
   my $origin_cell = shift;
   my $target_cell = shift;

   # Store the highest generation of the two cells...
   my $max_gen = $origin_cell->{gen} >= $target_cell->{gen}
                                                     ? $origin_cell->{gen}
                                                     : $target_cell->{gen};

   # Determine which cell is bigger in each dimension...
   # Order the two bitstrings, smaller one first...
   my ($small_lr, $big_lr) =
               sort sort_bitstrings($origin_cell->{lr}, $target_cell->{lr});

   my ($small_ud, $big_ud) =
               sort sort_bitstrings($origin_cell->{ud}, $target_cell->{ud});


   # Calculate the distance between the cells in each dimension...
   my $lr_distance = subtract_bitstrings($big_lr, $small_lr, $max_gen);
   my $ud_distance = subtract_bitstrings($big_ud, $small_ud, $max_gen);

   debug_vector("lr distance = ", $lr_distance);
   debug_vector("ud distance = ", $ud_distance);


   # Convert the radius into the smallest bitstring that can cover it...
   my $radius_gen = 8;
   my $rad_bs = length_to_bitstring($radius, $radius_gen);

   debug_vector("rad_bs = ", $rad_bs);

   # Finally, see if the cell falls within a box of the required radius...
   return 1 if (    compare_bitstrings($rad_bs, $lr_distance, $radius_gen) >= 0
                 && compare_bitstrings($rad_bs, $ud_distance, $radius_gen) >= 0 );

   # If not, return false...
   return 0;
}


=item B<length_to_bitstring>

Given a length expressed as a fraction of the grid length, and the maximum
generation of a cell in the grid, returns the binary representation of that
length, to the maximum fidelity of the grid. Note that partial remainders are
included - this function will always cover the full radius, and any extra
overlap forced by the (lack of) grid precision.

$rad_bs = length_to_bitstring($radius, $max_gen);

=cut
sub length_to_bitstring {
   my $box_frac_length  = shift;  # Fraction of the length of the full grid
   my $max_gen   = shift;  # Highest bit representation specifiable on this grid


   my $rad_bs = '';
   vec($rad_bs, 0, 1) = 0;

   # Iterate over the bits, most significant first...
   for my $idx (0..$max_gen-1) {
      # Scale the box length to the current bit representation...
      $box_frac_length = $box_frac_length * 2;

      debug("idx, box frac length = $idx, $box_frac_length");

      # If there is something to store, store it, and decrement...
      if ( $box_frac_length >= 1 ) {
         vec($rad_bs, $idx, 1) = 1;
         $box_frac_length--;
      }
      # We've run out of number (exact computation)- return...
      elsif ( $box_frac_length < 0 ) {
         return $rad_bs;
      }

   }

   # We've run out of bitstring precision. If there's any fraction left over,
   # set our least significant bit.
   vec($rad_bs, $max_gen-1, 1) = 1 if ( $box_frac_length > 0 );

   return $rad_bs;
}


=item B<cell_is_in_list>

Returns true if $cell is found in @list. Cells are compared by id
(NOT bitstring).

$cell_present = cell_is_in_list($cell, @list);

=cut
sub cell_is_in_list {
   my $cell = shift;

   while ( @_ ) {
      my $next_in_list = shift;
      return 1 if $cell->{id} == $next_in_list->{id};
   }

   return 0;
}


=item B<edge_is_in_list>

Returns true if $edge is in @list, or false otherwise.

$edge_present = edge_is_in_list($edge, @list);

=cut
sub edge_is_in_list {
   my $edge = shift;
   my $list = shift;

   foreach my $next_in_list ( @{$list} ) {

      return 1 if (  (  ( $edge->[0]->{id} == $next_in_list->[0]->{id} )
                     && ( $edge->[1]->{id} == $next_in_list->[1]->{id} ) )
                 ||
                  (     ( $edge->[1]->{id} == $next_in_list->[0]->{id} )
                     && ( $edge->[0]->{id} == $next_in_list->[1]->{id} ) ) );
   }

   return 0;
}


=item B<deduce_siblings>

Calculates the bitstrings of the siblings of the provided cell, based on the
fact that cells are always quadrisected into groups of four children.

[$horiz_sibling, $vert_sibling] = deduce_siblings($target_cell);

=cut
sub deduce_siblings {
   my $me = shift;

   # Extract the L-R for the most recent generation...
   my $lr = vec($me->{lr},$me->{gen},1);

   # Do the same with U-D...
   my $ud = vec($me->{ud},$me->{gen},1);

   # Now build the cells of our two siblings...
   my $horiz_sibling = {
                         lr  => $me->{lr},
                         ud  => $me->{ud},
                         gen => $me->{gen},
                       };

   my $vert_sibling = {
                         lr  => $me->{lr},
                         ud  => $me->{ud},
                         gen => $me->{gen},
                       };


   # Set our horizontal sibling to have the opposite L-R bit from us...
   vec($horiz_sibling->{lr},$me->{gen}-1,1) = $lr^1;

   # Set our vertical sibling to have the opposite U-D bit from us...
   vec($vert_sibling->{ud},$me->{gen}-1,1) = $ud^1;

   return [$horiz_sibling, $vert_sibling];
}


=item B<grep_siblings>

Returns any cells in $cells_to_search matching the provided sibling bitstrings.

@sibling_cells = grep_siblings([$horiz_sibling, $vert_sibling],
                               $cells_to_search);

@sibling_cells = ($sibling_1, $sibling_2);

=cut
sub grep_siblings {
   my $siblings        = shift;
   my $candidate_cells = shift;

   my @neighbours;

   foreach my $candidate_cell ( @{$candidate_cells} ) {

      # Look for siblings...
      foreach my $sibling ( @{$siblings} ) {
         next unless defined $sibling;

         # If both the bitstrings match...
         if ( bitstrings_match($candidate_cell->{lr}, $sibling->{lr},
                               $candidate_cell->{gen}, $sibling->{gen})
           && bitstrings_match($candidate_cell->{ud}, $sibling->{ud},
                               $candidate_cell->{gen}, $sibling->{gen})
         ) {

            # ...then we've found a sibling...
            push @neighbours, $candidate_cell;
            $sibling = undef;

         }
      }
   }

   return @neighbours;
}


=item B<find_all_cell_corners>

Returns a list of corner coordinates for every provided cell.

@coords_list = find_all_cell_corners(@cells);

@coords = (
            [top_left_x1, top_left_y1, bot_left_x1, bot_left_y1],
            [top_left_x2, top_left_y2, bot_left_x2, bot_left_y2],
            ...
           );

=cut
sub find_all_cell_corners {
   my @all_cells_coords;

   # Keep going as long as there are cells to process...
   while ( @_ ) {
      my $next_to_process = shift;

      # Expand the array if it's a reference, otherwise store the single value..
      my @cells = ref($next_to_process) eq 'ARRAY' ? @{$next_to_process}
                                                   : ($next_to_process);


      # Iterate over each cell in this group...
      foreach my $cell ( @cells ) {

         # Determine the top left and bottom right corners...
         my @corner_coords = find_cell_corners($cell);

         # Store the corners...
         push @all_cells_coords, \@corner_coords;
      }
   }

   return @all_cells_coords;
}


=item B<find_cell_corners>

Returns the cell corners for the provided cell.

(top_left_x, top_left_y, bot_left_x, bot_left_y) = find_cell_corners($cell);

=cut
sub find_cell_corners {
   my $cell = shift;

   my ($x, $y, $cell_half_width) = find_cell_centre($cell);

   my @coords;

   # Store the top left corner...
   push @coords, $x-$cell_half_width;
   push @coords, $y-$cell_half_width;

   # Store the bottom right corner...
   push @coords, $x+$cell_half_width;
   push @coords, $y+$cell_half_width;

   return @coords;
}


=item B<find_cell_centre>

Decodes the binary scheme of a given cell to determine the cell centre in pixel
coordinates.

(x, y, baselength) = find_cell_centre(cell);

=cut
sub find_cell_centre {
   my $cell = shift;

   my $cur_x          = 250;
   my $cur_y          = 250;
   my $cur_baselength = 100;

   # Iterate over the bitstring, adjusting the position as we go...
   foreach my $bit_pos ( 0..$cell->{gen}-1 ) {
      $cur_baselength /= 2;

      # Consider L-R...
      my $lr_bit = vec($cell->{lr},$bit_pos,1);

      # A set bit means 'right', i.e. increasing value...
      $cur_x += $lr_bit ? $cur_baselength : -1 * $cur_baselength;

      # Consider U-D...
      my $ud_bit = vec($cell->{ud},$bit_pos,1);

      # A set bit means 'up', i.e. decreasing value...
      $cur_y += $ud_bit ? -1 * $cur_baselength : $cur_baselength;

   }

   return ($cur_x, $cur_y, $cur_baselength);
}


=item B<get_cell_0>

Instantiates and returns a root cell (generation 0).

=cut
sub get_cell_0 {

   my $base_bitstring1 = '';
   my $base_bitstring2 = '';
   vec($base_bitstring1,0,1) = 0;
   vec($base_bitstring2,0,1) = 0;

   my $cell_0 = {
                    lr  => $base_bitstring1,
                    ud  => $base_bitstring2,
                    gen => 0,
                    id  => 0,
                 };

   return $cell_0;
}

=back


=head1 UTILITY FUNCTIONS

Assorted debugging routines, including

=over

=item B<print_cell>

=item B<print_vector>

=item B<toggle_debugging>

=item B<debug>

=item B<debug_vector>

=item B<whowasi>

=back

=cut


sub print_cell {
   my $cell = shift;
   print "id  = $cell->{id}\n";
   print "gen = $cell->{gen}\n";
   print "lr  = ";
   print_vector($cell->{lr});
   print "ud  = ";
   print_vector($cell->{ud});
}


sub print_vector { print  unpack("b*", $_[0]), "\n" }

{


my $debug_flag = 0;
sub toggle_debugging {
   $debug_flag = ( $debug_flag == 0 ) ? 1 : 0;
}

sub debug {
   return unless $debug_flag;
   print 'DEBUG ['  . whowasi() . ']: ' . "$_[0]\n";
}

sub debug_vector {
   return unless $debug_flag;
   debug($_[0] . unpack("b*", $_[1]));
}

sub whowasi { (caller(2))[3] }

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

1;
