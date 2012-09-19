package AMR::Test;

=head1 NAME

AMR::Test - Pre-built cells for testing AMR.

=cut

=head1 VERSION 1.0

Eric Saunders, June 2008

=cut


use strict;
use warnings;

require Exporter;
use vars qw( $VERSION @EXPORT_OK %EXPORT_TAGS @ISA );

@ISA = qw( Exporter );
@EXPORT_OK = qw(
                  get_first_test_grid
                  get_gen1_cells
                  get_gen2_cells
                  get_gen3_cells
                  get_second_test_grid
                );

%EXPORT_TAGS = (
                  'all' => [ qw(
                                 get_first_test_grid
                                 get_gen1_cells
                                 get_gen2_cells
                                 get_gen3_cells
                                 get_second_test_grid
                               )
                           ],
                 );


=head1 EXPORTED ROUTINES

=over


=item B<get_first_test_grid>

Returns a three generation grid of 12 cells that looks like this:


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


 @grid = get_first_test_grid();

 @grid = (
          [cell_1, cell_2, cell_3, cell_4],
          [cell 5, cell 6, cell_7, cell_8],
          [cell 9, cell 10, cell_11, cell_12]
         );

=cut
sub get_first_test_grid {

   my @all_cells = (get_gen1_cells(), get_gen2_cells(),
                    get_gen3_cells());


   return @all_cells;
}


=item B<get_gen1_cells>

Returns cells 1,2,3,4 of the test grid.

[cell_1, cell_2, cell_3, cell_4] = get_gen1_cells();

=cut
sub get_gen1_cells {

   # Set up the bitstring datastructure...
   my $gen1 =
              [
                 {
                    id => 1,
                    lr => '',
                    ud => '',
                    gen => 1,
                 },
                 {
                    id => 2,
                    lr => '',
                    ud => '',
                    gen => 1,
                 },
                 {
                    id => 3,
                    lr => '',
                    ud => '',
                    gen => 1,
                 },
                 {
                    id => 4,
                    lr => '',
                    ud => '',
                    gen => 1,
                 },
              ];

   # Initialise the bitstrings...

   # Set generation 1, first cell, left-right and up-down bitstrings...
   # 0 = left, 1 = right
   # 0 = down, 1 = up

   vec($gen1->[0]->{lr},0,1) = 0;
   vec($gen1->[0]->{ud},0,1) = 1;

   # Set the rest of generation 1...
   vec($gen1->[1]->{lr},0,1) = 1;
   vec($gen1->[1]->{ud},0,1) = 1;

   vec($gen1->[2]->{lr},0,1) = 0;
   vec($gen1->[2]->{ud},0,1) = 0;

   vec($gen1->[3]->{lr},0,1) = 1;
   vec($gen1->[3]->{ud},0,1) = 0;

   return $gen1;
}


=item B<get_gen2_cells>

Returns cells 5,6,7,8 of the test grid.

[cell_5, cell_6, cell_7, cell_8] = get_gen2_cells();

=cut
sub get_gen2_cells {

   # Set up the bitstring datastructure...
   my $gen2 =
              [
                 {
                    id => 5,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 6,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 7,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 8,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
              ];

   # Initialise the bitstrings...

   # Set generation 2, first cell, left-right and up-down bitstrings...
   # 0 = left, 1 = right
   # 0 = down, 1 = up

   vec($gen2->[0]->{lr},0,1) = 0b1;       # (lr = 10)
   vec($gen2->[0]->{ud},0,2) = 0b11;     # (ud = 11)


   # Set the rest of generation 2...
   vec($gen2->[1]->{lr},0,2) = 0b11;
   vec($gen2->[1]->{ud},0,2) = 0b11;

   vec($gen2->[2]->{lr},0,1) = 0b1;  #10
   vec($gen2->[2]->{ud},0,1) = 0b1;  #10

   vec($gen2->[3]->{lr},0,2) = 0b11;
   vec($gen2->[3]->{ud},0,1) = 0b1;  # 10

   return $gen2;
}



=item B<get_gen3_cells>

Returns cells 9,10,11,12 of the test grid.

[cell_9, cell_10, cell_11, cell_12] = get_gen3_cells();

=cut
sub get_gen3_cells {

   # Set up the bitstring datastructure...
   my $gen3 =
              [
                 {
                    id => 9,
                    lr => '',
                    ud => '',
                    gen => 3,
                 },
                 {
                    id => 10,
                    lr => '',
                    ud => '',
                    gen => 3,
                 },
                 {
                    id => 11,
                    lr => '',
                    ud => '',
                    gen => 3,
                 },
                 {
                    id => 12,
                    lr => '',
                    ud => '',
                    gen => 3,
                 },
              ];

   # Initialise the bitstrings...

   # Set generation 3, first cell, left-right and up-down bitstrings...
   # 0 = left, 1 = right
   # 0 = down, 1 = up

   vec($gen3->[0]->{lr},0,1) = 0b1;  #100
   vec($gen3->[0]->{ud},0,4) = 0b101;

   # Set the rest of generation 3...
   vec($gen3->[1]->{lr},0,4) = 0b101;
   vec($gen3->[1]->{ud},0,4) = 0b101;

   vec($gen3->[2]->{lr},0,1) = 0b1;   #100
   vec($gen3->[2]->{ud},0,1) = 0b1;   #100

   vec($gen3->[3]->{lr},0,4) = 0b101;
   vec($gen3->[3]->{ud},0,1) = 0b1;   #100

   return $gen3;
}


=item B<get_second_test_grid>

Returns a two generation grid of 12 cells that looks like this:


 id=1
  L 0 |----------
  U 1 |
      |   ----------- ----------- -----------------------
      |  |           |           |                       |
      |  |   id=5    |   id=6    |                       |
      |  |           |           |         id=2          |
      |  |   LL 00   |   LR 01   |                       |
         |   UU 11   |   UU 11   |         R  1          |
          ----------- -----------          U  1          |
         |           |           |                       |
         |   id=7    |   id=8    |                       |
         |           |           |                       |
         |   LL 00   |   LR 01   |                       |
         |   UD 10   |   UD 10   |                       |
          ----------- ----------- -----------------------|
         |           |           |                       |
         |   id=9    |   id=10   |                       |
         |           |           |         id=4          |
         |   LL 00   |   LR 01   |                       |
         |   DU 01   |   DU 01   |         R  1          |
          ----------- -----------          D  0          |
         |           |           |                       |
         |   id=11   |   id=12   |                       |
         |           |           |                       |
         |   LL 00   |   LL 01   |                       |
      |  |   DD 00   |   DD 00   |                       |
      |   ----------------------- -----------------------
      |-----
 id=3
  L 0
  D 0


 @grid = get_second_test_grid();

 @grid = (
          [cell_1, cell_2, cell_3, cell_4],
          [cell 5, cell 6, cell_7, cell_8,
          cell 9, cell 10, cell_11, cell_12]
         );

=cut
sub get_second_test_grid {

   my $gen1 =
              [
                 {
                    id => 1,
                    lr => '',
                    ud => '',
                    gen => 1,
                 },
                 {
                    id => 2,
                    lr => '',
                    ud => '',
                    gen => 1,
                 },
                 {
                    id => 3,
                    lr => '',
                    ud => '',
                    gen => 1,
                 },
                 {
                    id => 4,
                    lr => '',
                    ud => '',
                    gen => 1,
                 },
              ];

   my $gen2 =
              [
                 {
                    id => 5,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 6,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 7,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 8,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 9,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 10,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 11,
                    lr => '',
                    ud => '',
                    gen => 2,
                 },
                 {
                    id => 12,
                    lr => '',
                    ud => '',
                    gen => 2,
                 }
              ];


   # Initialise the bitstrings...

   # Set generation 1, first cell, left-right and up-down bitstrings...
   # 0 = left, 1 = right
   # 0 = down, 1 = up

   vec($gen1->[0]->{lr},0,1) = 0;
   vec($gen1->[0]->{ud},0,1) = 1;

   # Set the rest of generation 1...
   vec($gen1->[1]->{lr},0,1) = 1;
   vec($gen1->[1]->{ud},0,1) = 1;

   vec($gen1->[2]->{lr},0,1) = 0;
   vec($gen1->[2]->{ud},0,1) = 0;

   vec($gen1->[3]->{lr},0,1) = 1;
   vec($gen1->[3]->{ud},0,1) = 0;


   # Set generation 2...
   # 0 = left, 1 = right
   # 0 = down, 1 = up

   # id 5 = 00 , 11
   vec($gen2->[0]->{lr},0,1) = 0;
   vec($gen2->[0]->{ud},0,2) = 0b11;

   # id 6 = 01 , 11
   vec($gen2->[1]->{lr},1,1) = 1;
   vec($gen2->[1]->{ud},0,2) = 0b11;

   # id 7 = 00 , 10
   vec($gen2->[2]->{lr},0,1) = 0;
   vec($gen2->[2]->{ud},0,1) = 1;

   # id 8 = 01 , 10
   vec($gen2->[3]->{lr},1,1) = 1;
   vec($gen2->[3]->{ud},0,1) = 1;

   # id 9 = 00 , 01
   vec($gen2->[4]->{lr},0,1) = 0;
   vec($gen2->[4]->{ud},1,1) = 1;

   # id 10 = 01 , 01
   vec($gen2->[5]->{lr},1,1) = 1;
   vec($gen2->[5]->{ud},1,1) = 1;

   # id 11 = 00 , 00
   vec($gen2->[6]->{lr},0,1) = 0;
   vec($gen2->[6]->{ud},0,1) = 0;

   # id 12 = 01 , 00
   vec($gen2->[7]->{lr},1,1) = 1;
   vec($gen2->[7]->{ud},0,1) = 0;

   return ($gen1, $gen2);
}


=back


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
