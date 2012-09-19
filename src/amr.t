#!/usr/bin/perl

# amr.t - Unit tests for AMR.
# Eric Saunders, June 2008

use strict;
use warnings;

use Test::More tests => 102;

BEGIN { use_ok('AMR'); use_ok('AMR::Test') }

use AMR       qw(:all);
use AMR::Test qw(:all);


# Test cell_is_in_list...
{
   my $cells_to_search = get_gen1_cells();
   my $cell = $cells_to_search->[0];

   is(cell_is_in_list($cell, @{$cells_to_search}), 1, 'cell_is_in_list');
}

# Test cell_is_in_list...
{
   my $cells_to_search = get_gen1_cells();
   my $cell = {
                id => 10,
               };

   is(cell_is_in_list($cell, @{$cells_to_search}), 0, 'cell_is_in_list');
}


# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[0]->[2];     # Generation 1, cell id 3...
   my $dir = 'r';


   my $expected_cell = $cells_to_search[0]->[3];    # Generation 1, cell id 4...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell, 'get_next_cell - same size, first generation, r, xdim');
}


# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[0]->[3];     # Generation 1, cell id 4...
   my $dir = 'r';


   my $expected_cell = undef;    # Generation 1, cell id 4...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell, 'get_next_cell - first generation, at r edge of x dim');
}


# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[0]->[0];     # Generation 1, cell id 1...
   my $dir = 'r';


   my $expected_cell = $cells_to_search[2]->[2];   # Generation 3, cell id 11...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - first generation to third generation, r, xdim');

   # For simpler debugging (same test as above)...
   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search)->{id},
      $expected_cell->{id},
      'get_next_cell - first generation to third generation, r, xdim');
}


# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[2]->[3];    # Generation 3, cell id 12...
   my $dir = 'r';


   my $expected_cell = $cells_to_search[1]->[3];   # Generation 2, cell id 8...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - third generation to second generation, r, xdim');

   # For simpler debugging (same test as above)...
   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search)->{id},
      $expected_cell->{id},
      'get_next_cell - third generation to second generation, r, xdim');
}


# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[0]->[2];    # Generation 1, cell id 3...
   my $dir = 'u';


   my $expected_cell = $cells_to_search[0]->[0];   # Generation 1, cell id 1...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - same size, first generation, u, ydim');

   # For simpler debugging (same test as above)...
   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search)->{id},
      $expected_cell->{id},
      'get_next_cell - same size, first generation, u, ydim');
}


# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[0]->[0];    # Generation 1, cell id 1...
   my $dir = 'u';


   my $expected_cell = undef;

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - first generation, u, at edge of ydim');
}

# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[0]->[3];     # Generation 1, cell id 4...
   my $dir = 'l';


   my $expected_cell = $cells_to_search[0]->[2];    # Generation 1, cell id 3...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell, 'get_next_cell - same size, first generation, l, xdim');
}

# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[0]->[2];     # Generation 1, cell id 3...
   my $dir = 'l';


   my $expected_cell = undef;    # Generation 1, cell id 4...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell, 'get_next_cell - first generation, at l edge of x dim');
}


# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[1]->[3];     # Generation 2, cell id 8...
   my $dir = 'l';


   my $expected_cell = $cells_to_search[2]->[3];   # Generation 3, cell id 12...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - first generation to third generation, r, xdim');

   # For simpler debugging (same test as above)...
   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search)->{id},
      $expected_cell->{id},
      'get_next_cell - second generation to first generation, l, xdim');
}

# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[0]->[2];    # Generation 1, cell id 3...
   my $dir = 'd';


   my $expected_cell = undef;

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - first generation, d, at edge of ydim');
}

# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[1]->[1];    # Generation 2, cell id 6...
   my $dir = 'd';


   my $expected_cell = $cells_to_search[1]->[3];

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - same generation, d, ydim');
}

# Test get_next_cell...
{
   my @cells_to_search = get_first_test_grid();
   my $max_gen = 3;
   my $current_cell = $cells_to_search[1]->[0];    # Generation 2, cell id 5...
   my $dir = 'd';


   my $expected_cell = $cells_to_search[2]->[0];   # Generation 3, cell id 9...

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - second to first generation, d, ydim');
}

# Test get_next_cell...
{
   my @cells_to_search = get_second_test_grid();
   my $max_gen = 2;
   my $current_cell = $cells_to_search[0]->[1];    # Generation 1, cell id 2...
   my $dir = 'l';


   my $expected_cell = $cells_to_search[1]->[3];   # Generation 2, cell id 8...


   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search)->{id},
      $expected_cell->{id},
      'get_next_cell - alternate grid');

   is(get_next_cell($current_cell, $dir, $max_gen, @cells_to_search),
      $expected_cell,
      'get_next_cell - alternate grid');
}

{
   my @cells_to_search = get_second_test_grid();
   my $max_gen = 2;
   my $current_cell = $cells_to_search[0]->[1];    # Generation 1, cell id 2...
   my $dir = 'l';

   my $expected_bs = '01000000';

   is(unpack("b*", find_next_cell_bitstring($current_cell->{lr}, 'l', $max_gen)),
         $expected_bs, 'find_next_cell_bitstring - alternate grid');
}


# Test bitstrings_match...
{
   my $bs1 = '';
   my $bs2 = '';
   my $bs3 = '';
   my $bs4 = '';
   my $bs5 = '';
   my $bs6 = '';

   vec($bs1,0,1) = 0;
   vec($bs2,0,4) = 0b0000;
   vec($bs3,0,1) = 1;
   vec($bs4,3,1) = 1;
   vec($bs5,0,8) = 0b10101010;
   vec($bs6,1,4) = 0b1111;

   is(bitstrings_match($bs1, $bs2, 4), 1, 'bitstrings_match - all zeros');
   is(bitstrings_match($bs1, $bs3, 1), 0, 'bitstrings_match - differing');
   is(bitstrings_match($bs1, $bs3, 4), 0, 'bitstrings_match - differing');
   is(bitstrings_match($bs5, $bs5, 8), 1, 'bitstrings_match - 8 bits');
   is(bitstrings_match($bs2, $bs6, 4), 1,
                              'bitstrings_match - mismatch beyond generation');
   is(bitstrings_match($bs5, $bs5, 4, 8), 1,
                              'bitstrings_match - highest generation used');
}

# Test find_next_cell_bitstring...
{
   my $bs1 = '';
   my $bs2 = '';
   my $bs3 = '';
   my $bs4 = '';
   my $bs5 = '';
   my $bs6 = '';

   vec($bs1,0,1) = 0;        # The first generation vector 0
   vec($bs2,0,4) = 0b101;    # The 4th generation vector 1010
   vec($bs3,1,1) = 1;        # The 2nd generation vector 01

   vec($bs4,0,1) = 0;
   vec($bs4,1,1) = 1;
   vec($bs4,2,1) = 1;
   vec($bs4,3,1) = 1;        # The 4th generation vector 0111

   vec($bs5,0,4) = 0b1111;
   vec($bs5,4,1) = 1;        # The 5th generation vector 11111

   vec($bs6,0,1) = 0;        # The 3rd generation vector 000

   is(unpack("b*", find_next_cell_bitstring($bs1, '+', 1)), '10000000',
                                                'find_next_cell_bitstring');
   is(unpack("b*", find_next_cell_bitstring($bs2, '+', 4)), '10110000',
                                                'find_next_cell_bitstring');
   is(unpack("b*", find_next_cell_bitstring($bs3, '+', 2)), '10000000',
                                                'find_next_cell_bitstring');
   is(unpack("b*", find_next_cell_bitstring($bs4, '+', 4)), '10000000',
                                                'find_next_cell_bitstring');
   is(unpack("b*", find_next_cell_bitstring($bs5, '+', 5)), '11111000',
                           'find_next_cell_bitstring - unincrementable bs');
   is(unpack("b*", find_next_cell_bitstring($bs6, '+', 3)), '00100000',
                           'find_next_cell_bitstring - all zeros');


   is(unpack("b*", find_next_cell_bitstring($bs1, '-', 1)), '00000000',
                                                'find_next_cell_bitstring');
   is(unpack("b*", find_next_cell_bitstring($bs2, '-', 4)), '10010000',
                                                'find_next_cell_bitstring');
   is(unpack("b*", find_next_cell_bitstring($bs3, '-', 2)), '00000000',
                                                'find_next_cell_bitstring');
   is(unpack("b*", find_next_cell_bitstring($bs4, '-', 4)), '01100000',
                                                'find_next_cell_bitstring');
}


# Test subtract_bitstrings...
{
   my $bs1 = '';
   my $bs2 = '';
   my $expected_bs = '00000000';
   my $gen = 4;

   is(unpack("b*", subtract_bitstrings($bs1, $bs2, $gen)), $expected_bs,
                                             'subtract_bitstrings - all zeros');
}

# Test subtract_bitstrings...
{
   my $bs1 = '';
   my $bs2 = '';

   vec($bs1, 0, 1) = 1;  # 100
   my $bs1_gen = 3;

   vec($bs2, 0, 1) = 1;  # 10
   my $bs2_gen = 2;

   my $expected_bs = '00000000';

   is(unpack("b*", subtract_bitstrings($bs1, $bs2, $bs1_gen)),
                     $expected_bs, 'subtract_bitstrings - bs1 longer than bs2');
}

# Test subtract_bitstrings...
{
   my $bs1 = '';
   my $bs2 = '';

   vec($bs1, 0, 1) = 1;  # 10
   my $bs1_gen = 2;

   vec($bs2, 0, 1) = 1;  # 100
   my $bs2_gen = 3;

   my $expected_bs = '00000000';

   is(unpack("b*", subtract_bitstrings($bs1, $bs2, $bs1_gen)),
                     $expected_bs, 'subtract_bitstrings - bs2 longer than bs1');
}


# Test subtract_bitstrings...
{
   my $bs1 = '';
   my $bs2 = '';

   vec($bs1, 0, 4) = 0b111;  # 100
   my $bs1_gen = 3;

   vec($bs2, 0, 2) = 0b11;  # 10
   my $bs2_gen = 2;

   my $expected_bs = '00100000';

   is(unpack("b*", subtract_bitstrings($bs1, $bs2, $bs1_gen)),
                   $expected_bs, 'subtract_bitstrings - non-carrying subtract');
}


# Test subtract_bitstrings...
{
   my $bs1 = '';
   my $bs2 = '';

   vec($bs1, 0, 4) = 0b101;  # 1010
   my $bs1_gen = 4;

   vec($bs2, 3, 1) = 1;      # 0001
   my $bs2_gen = 4;

   my $expected_bs = '10010000';

   is(unpack("b*", subtract_bitstrings($bs1, $bs2, $bs1_gen)),
                   $expected_bs, 'subtract_bitstrings - carrying subtract');
}


# Test subtract_bitstrings...
{
   my $bs1 = '';
   my $bs2 = '';

   vec($bs1, 0, 1) = 0;      # 0000
   my $bs1_gen = 4;

   vec($bs2, 3, 1) = 1;      # 0001
   my $bs2_gen = 4;

   my $expected_bs = '00000000';

   is(unpack("b*", subtract_bitstrings($bs1, $bs2, $bs1_gen)),
                   $expected_bs, 'subtract_bitstrings - unresolvable carrys');
}


# Test subtract_bitstrings...
{
   my $bs1 = '';
   my $bs2 = '';

   vec($bs1, 0, 2) = 0b11;   # 11
   my $bs1_gen = 2;


   vec($bs2, 0, 4) = 0b101;  # 101
   my $bs2_gen = 3;

   my $expected_bs = '00100000';

   is(unpack("b*", subtract_bitstrings($bs1, $bs2, $bs2_gen)),
                   $expected_bs, 'subtract_bitstrings - carrying subtract');
}


# Test find_matching_cell...
{
   my $x_bitstring = '';
   my $y_bitstring = '';

   # Cell 9: RLL (100), UDU (101)
   vec($x_bitstring,0,1) = 1;
   vec($y_bitstring,0,4) = 0b101;
   my $gen = 3;

   my @cells = get_first_test_grid();

   my $cell = find_matching_cell($x_bitstring, $y_bitstring, $gen, @cells);

   is($cell->{id}, 9, 'find_matching_cell - exact cell found');
}


# Test find_matching_cell...
{
   my $x_bitstring = '';
   my $y_bitstring = '';

   # Want cell 4: RR (11), DD (00), but specify a child that doesn't exist...
   vec($x_bitstring,0,4) = 0b111;
   vec($y_bitstring,0,1) = 0;
   my $gen = 3;

   my @cells = get_first_test_grid();

   my $cell = find_matching_cell($x_bitstring, $y_bitstring, $gen, @cells);

   is($cell->{id}, 4, 'find_matching_cell - closest parent cell found');
}


# Test find_matching_cell...
{
   my $x_bitstring = '';
   my $y_bitstring = '';

   vec($x_bitstring,0,4) = 0b11;
   vec($y_bitstring,0,1) = 1;
   my $gen = 3;

   my @cells = get_first_test_grid();

   my $cell = find_matching_cell($x_bitstring, $y_bitstring, $gen, @cells);

   is($cell->{id}, 8, 'find_matching_cell - Bug fix from real-world run');
}


# Test find_matching_cell...
{
   my $x_bitstring = '';
   my $y_bitstring = '';

   vec($x_bitstring,0,1) = 1;
   vec($y_bitstring,0,1) = 0;
   my $gen = 3;

   my @cells = get_first_test_grid();

   my $cell = find_matching_cell($x_bitstring, $y_bitstring, $gen, @cells);

   is($cell->{id}, 4, 'find_matching_cell - Bug fix from real-world run');
}



# Test crawl_grid...
{
   my @cells_to_search = get_first_test_grid();

   my $n_gen = 3;

   my @cells;
   my $current_cell = $cells_to_search[0]->[2];   # First generation, cell id 3

   my $edges = crawl_grid($current_cell, $n_gen, [],
                          sub { !AMR::edge_is_in_list(@_) }, @cells_to_search);

   my $gen1 = $cells_to_search[0];
   my $gen2 = $cells_to_search[1];
   my $gen3 = $cells_to_search[2];

   my $expected_edges = [
                          [$gen1->[2], $gen1->[3]],  #  3 <-> 4
                          [$gen1->[3], $gen3->[2]],  #  4 <-> 11
                          [$gen3->[2], $gen3->[3]],  # 11 <-> 12
                          [$gen3->[3], $gen2->[3]],  # 12 <-> 8
                          [$gen2->[3], $gen2->[1]],  #  8 <-> 6
                          [$gen2->[1], $gen2->[0]],  #  6 <-> 5
                          [$gen2->[0], $gen1->[0]],  #  5 <-> 1
                          [$gen1->[0], $gen3->[2]],  #  1 <-> 11
                          [$gen3->[2], $gen3->[0]],  # 11 <-> 9
                          [$gen3->[0], $gen3->[1]],  #  9 <-> 10
                          [$gen3->[1], $gen2->[3]],  # 10 <-> 8
                          [$gen2->[3], $gen1->[3]],  #  8 <-> 4
                          [$gen3->[1], $gen2->[0]],  # 10 <-> 5
                          [$gen2->[0], $gen3->[0]],  #  5 <-> 9
                          [$gen3->[0], $gen1->[0]],  #  9 <-> 1
                          [$gen1->[0], $gen1->[2]],  #  1 <-> 3
                          [$gen3->[1], $gen3->[3]],  # 10 <-> 12
                          [$gen3->[3], $gen1->[3]],  # 12 <-> 4
                         ];

   is_deeply($edges, $expected_edges, 'crawl_grid - correct edge set');
}


# Test build_neighbour_list...
{
   my @cells_to_search = get_first_test_grid();

   my $n_gen = 3;

   my @cells;
   my $current_cell = $cells_to_search[0]->[2];   # First generation, cell id 3

   my $edges = build_neighbour_list($current_cell, $n_gen, @cells_to_search);


   my $gen1 = $cells_to_search[0];
   my $gen2 = $cells_to_search[1];
   my $gen3 = $cells_to_search[2];

   my $expected_edges = [
                          [$gen1->[2], $gen1->[3]],  #  3 <-> 4
                          [$gen1->[3], $gen3->[2]],  #  4 <-> 11
                          [$gen3->[2], $gen3->[3]],  # 11 <-> 12
                          [$gen3->[3], $gen2->[3]],  # 12 <-> 8
                          [$gen2->[3], $gen2->[1]],  #  8 <-> 6
                          [$gen2->[1], $gen2->[0]],  #  6 <-> 5
                          [$gen2->[0], $gen1->[0]],  #  5 <-> 1
                          [$gen1->[0], $gen3->[2]],  #  1 <-> 11
                          [$gen3->[2], $gen3->[0]],  # 11 <-> 9
                          [$gen3->[0], $gen3->[1]],  #  9 <-> 10
                          [$gen3->[1], $gen2->[3]],  # 10 <-> 8
                          [$gen2->[3], $gen1->[3]],  #  8 <-> 4
                          [$gen3->[1], $gen2->[0]],  # 10 <-> 5
                          [$gen2->[0], $gen3->[0]],  #  5 <-> 9
                          [$gen3->[0], $gen1->[0]],  #  9 <-> 1
                          [$gen1->[0], $gen1->[2]],  #  1 <-> 3
                          [$gen3->[1], $gen3->[3]],  # 10 <-> 12
                          [$gen3->[3], $gen1->[3]],  # 12 <-> 4
                         ];

   is_deeply($edges, $expected_edges, 'build_neighbour_list - correct edge set');
}


# Test get_cell_neighbours...
{
   my @cells_to_search = get_first_test_grid();

   my $n_gen = 3;

   my @cells;
   my $current_cell = $cells_to_search[0]->[2];   # First generation, cell id 3

   my $edges
      = build_neighbour_list($current_cell, $n_gen, @cells_to_search);

   my $expected_neighbours = [$cells_to_search[0]->[3],
                              $cells_to_search[0]->[0]];

   is_deeply(get_cell_neighbours($current_cell, $edges), $expected_neighbours,
                                       'get_cell_neighbours - same generation');
}


# Test build_random_grid...
{
   my $n_cells = 36;
   my $max_gen = 0;

   my ($grid_cells, $highest_gen) = build_random_grid($n_cells);

   is(scalar @{$grid_cells}, $n_cells-4,
         'build_random_grid - correct number of cells');
}

# Test build_random_grid...
{
   my $n_cells = 5;
   my $max_gen = 1;

   my ($grid_cells, $highest_gen) = build_random_grid($n_cells);

   is(scalar @{$grid_cells}, $n_cells-1,
            'build_random_grid - correct number of cells');
   is($highest_gen, 1, 'build_random_grid - correct number of cells');
}


# Test quadrisect_grid...
{
   my $n_cells = 33;

   my $starting_gen = 0;
   my $starting_id = 0;
   my $cell_0 = get_cell_0();

   my ($grid_cells, $highest_gen) = quadrisect_grid($n_cells, $starting_gen,
                                                    $starting_id, $cell_0);

   is(scalar @{$grid_cells}, $n_cells,
                              'quadrisect_grid - correct number of cells');
}

# Test quadrisect_grid...
{
   my $n_cells = 5;

   my $starting_gen = 0;
   my $starting_id = 0;
   my $cell_0 = get_cell_0();

   my ($grid_cells, $highest_gen) = quadrisect_grid($n_cells, $starting_gen,
                                                      $starting_id, $cell_0);

   is(scalar @{$grid_cells}, $n_cells,
                       'quadrisect_grid - correct number of cells');
   is($highest_gen, 1, 'quadrisect_grid - correct highest generation');
}


# Test cell_is_within_radius...
{

   my @cells = get_first_test_grid();

   my $radius = 1;
   my $origin_cell = $cells[0]->[0];                 # Cell id 1
   my $target_cell = $cells[0]->[1];                 # Cell id 2

   is(cell_is_within_radius($radius, $origin_cell, $target_cell), 1,
                                                   'cell_is_within_radius');
}


# Test cell_is_within_radius...
{

   my @cells = get_first_test_grid();

   my $radius = 0.5;
   my $origin_cell = $cells[0]->[0];                 # Cell id 1
   my $target_cell = $cells[0]->[1];                 # Cell id 2

   is(cell_is_within_radius($radius, $origin_cell, $target_cell), 1,
                                  'cell_is_within_radius - exact radius limit');
}


# Test cell_is_within_radius...
{

   my @cells = get_first_test_grid();

   my $radius = 0.4;
   my $origin_cell = $cells[0]->[0];                 # Cell id 1
   my $target_cell = $cells[0]->[1];                 # Cell id 2

   is(cell_is_within_radius($radius, $origin_cell, $target_cell), 0,
                                                   'cell_is_within_radius');
}


# Test cell_is_within_radius...
{
   my @cells = get_first_test_grid();

   my $radius = 0.01;
   my $origin_cell = $cells[2]->[1];                 # Cell id 10
   my $target_cell = $cells[0]->[2];                 # Cell id 3

   is(cell_is_within_radius($radius, $origin_cell, $target_cell), 0,
                                                   'cell_is_within_radius');
}


# Test cell_is_within_radius...
{
   my @cells = get_first_test_grid();

   my $radius = 0.126;
   my $origin_cell = $cells[2]->[1];                 # Cell id 10
   my $target_cell = $cells[2]->[3];                 # Cell id 12

   is(cell_is_within_radius($radius, $origin_cell, $target_cell), 1,
                                                   'cell_is_within_radius');
}


# Test cell_is_within_radius...
{
   my @cells = get_first_test_grid();

   my $radius = 0.126;
   my $origin_cell = $cells[2]->[1];                 # Cell id 10
   my $target_cell = $cells[1]->[3];                 # Cell id 8

   is(cell_is_within_radius($radius, $origin_cell, $target_cell), 1,
                                                   'cell_is_within_radius');
}


# Test get_all_cells_within_radius...
{
   my @cells = get_first_test_grid();
   my $max_gen = 3;

   my $radius = 0.126;
   my $origin_cell = $cells[2]->[1];                 # Cell id 10

   my $edge_list = build_neighbour_list($cells[0]->[2], $max_gen, @cells);

   my $expected_cells = [
                          $cells[2]->[1], $cells[2]->[0], $cells[1]->[3],
                          $cells[1]->[0], $cells[2]->[3], $cells[2]->[2],
                          $cells[1]->[1]
                         ];

   is_deeply(get_all_cells_within_radius($origin_cell, $radius, $edge_list),
             $expected_cells, 'get_all_cells_within_radius - one cell width');
}


# Test get_all_cells_within_radius...
{
   my @cells = get_first_test_grid();
   my $max_gen = 3;

   my $radius = 0.124;
   my $origin_cell = $cells[2]->[1];                 # Cell id 10

   my $edge_list = build_neighbour_list($cells[0]->[2], $max_gen, @cells);

   my $expected_cells = [
                          $cells[2]->[1],
                         ];

   is_deeply(get_all_cells_within_radius($origin_cell, $radius, $edge_list),
     $expected_cells, 'get_all_cells_within_radius - less than one cell width');
}


# Test length_to_bitstring...
{
   my $length = 0.5;
   my $max_gen = 3;

   my $expected_bs = '10000000';

   is(unpack("b*", length_to_bitstring($length, $max_gen)), $expected_bs,
               'length_to_bitstring - exact division');
}


# Test length_to_bitstring...
{
   my $length = 0.75;
   my $max_gen = 3;

   my $expected_bs = '11000000';

   is(unpack("b*", length_to_bitstring($length, $max_gen)), $expected_bs,
               'length_to_bitstring - exact division at 2nd generation');

}


# Test length_to_bitstring...
{
   my $length = 0.8;
   my $max_gen = 3;

   my $expected_bs = '11100000';

   is(unpack("b*", length_to_bitstring($length, $max_gen)), $expected_bs,
               'length_to_bitstring - inexact division to 3 places');
}

# Test length_to_bitstring...
{
   my $length = 0.3;
   my $max_gen = 8;

   my $expected_bs = '01001101';

   is(unpack("b*", length_to_bitstring($length, $max_gen)), $expected_bs,
               'length_to_bitstring - inexact division to 8 places');
}



# Test length_to_bitstring...
{
   my $length = 1.0;
   my $max_gen = 3;

   my $expected_bs = '11100000';

   is(unpack("b*", length_to_bitstring($length, $max_gen)), $expected_bs,
           'length_to_bitstring - exact maximum to the resolution of the grid');
}


# Test length_to_bitstring...
{
   my $length = 1.8;
   my $max_gen = 3;

   my $expected_bs = '11100000';

   is(unpack("b*", length_to_bitstring($length, $max_gen)), $expected_bs,
        'length_to_bitstring - overflow maximum to the resolution of the grid');
}


# Test compare_bitstrings...
{
   my @cells = get_first_test_grid();
   my $bs1   = $cells[0]->[0]->{ud};         # Cell id 1
   my $bs2   = $cells[0]->[2]->{ud};         # Cell id 3

   my $gen   = $cells[0]->[0]->{gen};

   is(compare_bitstrings($bs1, $bs2, $gen), 1, 'compare_bitstrings - bs1 > bs2');
}


# Test compare_bitstrings...
{
   my @cells = get_first_test_grid();
   my $bs1   = $cells[0]->[0]->{lr};         # Cell id 1
   my $bs2   = $cells[0]->[2]->{lr};         # Cell id 3

   my $gen   = $cells[0]->[0]->{gen};

   is(compare_bitstrings($bs1, $bs2, $gen), 0, 'compare_bitstrings - bs1 == bs2');
}


# Test compare_bitstrings...
{
   my @cells = get_first_test_grid();
   my $bs1   = $cells[0]->[0]->{lr};         # Cell id 1
   my $bs2   = $cells[1]->[0]->{lr};         # Cell id 5

   my $gen   = $cells[1]->[0]->{gen};   # 2nd generation

   is(compare_bitstrings($bs1, $bs2, $gen), -1, 'compare_bitstrings - bs1 < bs2');
}


# Test deduce_siblings...
{
   my $gen1 = get_gen1_cells();
   my $me = $gen1->[2];
   my $siblings = deduce_siblings($me);

   my $expected_horiz_sibling = $gen1->[3];
   delete $expected_horiz_sibling->{id};

   is(unpack("b*", $siblings->[0]->{lr}),
      unpack("b*", $expected_horiz_sibling->{lr}),
                       'deduce_siblings - horizontal lr vector');

   is(unpack("b*", $siblings->[0]->{ud}),
      unpack("b*", $expected_horiz_sibling->{ud}),
                       'deduce_siblings - horizontal ud vector');


   my $expected_vert_sibling = $gen1->[0];
   delete $expected_vert_sibling->{id};

   is(unpack("b*", $siblings->[1]->{lr}),
      unpack("b*", $expected_vert_sibling->{lr}),
                       'deduce_siblings - vertical lr vector');

   is(unpack("b*", $siblings->[1]->{ud}),
      unpack("b*", $expected_vert_sibling->{ud}),
                       'deduce_siblings - vertical ud vector');


   is_deeply($siblings->[0], $expected_horiz_sibling,
                           'deduce_siblings - horizontal sibling');

   is_deeply($siblings->[1], $expected_vert_sibling,
                           'deduce_siblings - vertical sibling');

   is(scalar @{$siblings}, 2, 'deduce_siblings - exactly two siblings found');
}


# Test grep_siblings...
{
   my $gen1 = get_gen1_cells();
   my $me = $gen1->[2];
   my $siblings = deduce_siblings($me);

   my @neighbours = grep_siblings($siblings, $gen1);

   is(scalar @neighbours, 2, 'grep_siblings - exactly two siblings found');
   is($neighbours[0]->{id}, $gen1->[0]->{id}, 'grep_siblings - first sibling');
   is($neighbours[1]->{id}, $gen1->[3]->{id}, 'grep_siblings - second sibling');
}


# Test find_cell_centre...
{
   my $gen1 = get_gen1_cells();

   my $expected_x = 200;
   my $expected_y = 200;
   my $expected_cell_half_width = 50;

   my ($x, $y, $cell_half_width) = find_cell_centre($gen1->[0]);

   is($x, $expected_x, 'find_cell_centre - x-coord');
   is($y, $expected_y, 'find_cell_centre - y-coord');
   is($cell_half_width, $expected_cell_half_width,
                  'find_cell_centre - cell half-width');
}

# Test find_cell_centre...
{
   my $gen2 = get_gen2_cells();

   my $expected_x = 275;
   my $expected_y = 175;
   my $expected_cell_half_width = 25;

   my ($x, $y, $cell_half_width) = find_cell_centre($gen2->[0]);

   is($x, $expected_x, 'find_cell_centre - x-coord (gen 2)');
   is($y, $expected_y, 'find_cell_centre - y-coord (gen 2)');
   is($cell_half_width, $expected_cell_half_width,
               'find_cell_centre - cell half-width (gen 2)');
}


# Test find_cell_corner...
{
   my $gen1 = get_gen1_cells();

   my $expected_top_left_x     = 250;
   my $expected_top_left_y     = 150;
   my $expected_bottom_right_x = 350;
   my $expected_bottom_right_y = 250;


   my ($top_left_x, $top_left_y, $bottom_right_x, $bottom_right_y)
      = find_cell_corners($gen1->[1]);

   is($top_left_x, $expected_top_left_x, 'find_cell_corner - top left x');
   is($top_left_y, $expected_top_left_y, 'find_cell_corner - top left y');
   is($bottom_right_x, $expected_bottom_right_x,
                  'find_cell_corner - bottom right x');
   is($bottom_right_y, $expected_bottom_right_y,
                  'find_cell_corner - bottom right y');
}


{
   my $gen2 = get_gen2_cells();

   my $expected_top_left_x     = 250;
   my $expected_top_left_y     = 150;
   my $expected_bottom_right_x = 300;
   my $expected_bottom_right_y = 200;


   my ($top_left_x, $top_left_y, $bottom_right_x, $bottom_right_y)
      = find_cell_corners($gen2->[0]);

   is($top_left_x, $expected_top_left_x,
            'find_cell_corner - top left x (2nd gen)');
   is($top_left_y, $expected_top_left_y,
            'find_cell_corner - top left y (2nd gen)');
   is($bottom_right_x, $expected_bottom_right_x,
                  'find_cell_corner - bottom right x (2nd gen)');
   is($bottom_right_y, $expected_bottom_right_y,
                  'find_cell_corner - bottom right y (2nd gen)');
}


# Test find_all_cell_corners...
{
   my $gen1 = get_gen1_cells();

   my @expected_cell_coords = (
                                [150,150,250,250],
                                [250,150,350,250],
                                [150,250,250,350],
                                [250,250,350,350],
                               );

   my @cell_coords = find_all_cell_corners($gen1);

   is_deeply(\@cell_coords, \@expected_cell_coords,
                     'define_cells - single generation');
}


{
   my @all_bitstrings = get_first_test_grid();

   my @expected_cell_coords = (
                                [150,150,250,250],
                                [250,150,350,250],
                                [150,250,250,350],
                                [250,250,350,350],
                                [250,150,300,200],
                                [300,150,350,200],
                                [250,200,300,250],
                                [300,200,350,250],
                                [250,200,275,225],
                                [275,200,300,225],
                                [250,225,275,250],
                                [275,225,300,250],
                               );

   my @cell_coords = find_all_cell_corners(@all_bitstrings);

   is_deeply(\@cell_coords, \@expected_cell_coords,
                  'define_cells - multiple generations');
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
