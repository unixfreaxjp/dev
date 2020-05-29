#!/usr/bin/perl -w

# gendump : Generates an assembly dump of a given executable file.
# Copyright (C) 2002 Dion Mendel
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

# gendump generates an initial assembly dump of an executable file.
# Indexed jumps found in the disassembly are translated (e.g. switch
# statements).
# All non assembly lines are commented with either '#' or ';', or are blank.
# All other lines are assumed to contain assembly code.
# All decomp filters will apply to this generated file.
#
# Sample usage:
# % gendump the-binary > dump

use Getopt::Long "GetOptions";
use FileHandle;
use strict 'vars';
use vars '$VERSION', '$Verbose', '$Raw', '$OBJDUMP';

# full path to objdump program
$OBJDUMP = "/usr/bin/objdump";

$VERSION = "1.1";                            # version of this program
$Verbose = 1;
$Raw = 0;


&parse_command_line_for_options();
&usage if (scalar @ARGV != 1);

my $filename = $ARGV[0];

my ($next_start, $start, $end, $obj, @jumps);

# get sorted list of jump indexes
@jumps = sort {$a->{end_opcodes} <=> $b->{end_opcodes} } &get_indexed_jumps($filename);

# dump opcode data intersperced with jump indexes
$next_start = 0;
foreach $obj (@jumps) {
   $start = $next_start;
   $end = $obj->{end_opcodes};
   $next_start = $obj->{start_indexes} + 4 * $obj->{num_indexes};

   &dump($filename, $start, $end);
   &dump_indexes($filename, $obj->{num_indexes}, $obj->{start_indexes});
}

# dump last
&dump($filename, $next_start, 0xffffffff);

exit (0);


############################### Output Functions ##############################

# -----------------------------------------------------------------------------
# Prints the jump string for the given index.
# Params: $fh file handle to output to
#         $index index number
#         $str hex string in little endian order
# Returns: None

sub print_index($$$)
{
   my ($fh, $index, $str) = @_;
   my ($val);

   ($val = $str) =~ s/(..)(..)(..)(..)/0x$4$3$2$1/;
   printf $fh "# Indexed jump %02x %08x\n", $index, oct($val);
}

# -----------------------------------------------------------------------------
# Outputs jump index data from the given filename.
# Params: $filename name of file to disassemble
#         $num number of jump indexes
#         $start starting offset
# Returns: None

sub dump_indexes($$$)
{
   my ($filename, $num, $start) = @_;
   my ($cmd, $fh, $line, $end, $count, $num_so_far);

   $end = $start + 4 * $num;

   # perform disassembly
   $fh = new FileHandle;
   $cmd = "$OBJDUMP --start-address=$start --stop-address=$end " .
          "-s -j .text $filename";
   open $fh, "$cmd |" or die "couldn't run objdump: $!";

   $num_so_far = 0;
   $count = 0;
   while ($line = <$fh>) {
      chomp($line);

      # skip first 3 lines of output
      if ($count < 4) {
         $count += 1;
         next;
      }
      if (($num - $num_so_far) < 4) {
         if (($num - $num_so_far) > 0) {
            &print_index(STDOUT, $num_so_far, substr($line, 9, 8));
            $num_so_far++;
            if (($num - $num_so_far) > 0) {
               &print_index(STDOUT, $num_so_far, substr($line, 18, 8));
               $num_so_far++;
               if (($num - $num_so_far) > 0) {
                  &print_index(STDOUT, $num_so_far, substr($line, 27, 8));
                  $num_so_far++;
               }
            }
         }
      }
      else {
         &print_index(STDOUT, $num_so_far, substr($line, 9, 8));
         $num_so_far++;
         &print_index(STDOUT, $num_so_far, substr($line, 18, 8));
         $num_so_far++;
         &print_index(STDOUT, $num_so_far, substr($line, 27, 8));
         $num_so_far++;
         &print_index(STDOUT, $num_so_far, substr($line, 36, 8));
         $num_so_far++;
      }
   }
   close $fh;
}

# -----------------------------------------------------------------------------
# Outputs opcode data from the given filename.
# Params: $filename name of file to disassemble
#         $start starting offset
#         $end ending offset
# Returns: None

sub dump($$$)
{
   my ($filename, $start, $end) = @_;
   my ($cmd, $fh, $line, $offset, $data, $opcodes, $count);

   # perform disassembly
   $fh = new FileHandle;
   $cmd = "$OBJDUMP --start-address=$start --stop-address=$end " .
          "--show-raw-insn -d -j .text $filename";
   open $fh, "$cmd 2>/dev/null |" or die "couldn't run objdump: $!";

   $count = 0;
   # cleanup each line before outputing
   while ($line = <$fh>) {
      chomp($line);

      # skip first 5 lines of output
      if ($count < 6) {
         $count += 1;
         next;
      }

      if (index($line, "\t") != -1) {
         # all assembly lines include tab characters

         (undef, $data, $opcodes) = split(/\t/, $line);
         $offset = &line_offset($line);

         # ensure consistent output for jumps and calls
         if (defined $opcodes) {
            # all calls have operand as 8digit hex value preceeded by 0x
            $opcodes =~ s/(call\s+)(0x)?([0-9a-f]+)/
                          sprintf("%s0x%08x", $1, oct('0x' . $3))/eg;
            # all jumps have operand as 8digit hex value preceeded by 0x
            $opcodes =~ s/(j[a-z]+\s+)(0x)?([0-9a-f]+)/
                          sprintf("%s0x%08x", $1, oct('0x' . $3))/eg;
         }
         else {
            $opcodes = "";
         }

         # determine the line to output
         if ($Raw) {
            # compact data to save screen space
            if (defined $data) {
               chomp($data);
               $data =~ s/ //g;
            }
            $line = sprintf("%08x: %-15s%s", $offset, $data, $opcodes);
         }
         else {
            if ($opcodes ne "") {
               $line = sprintf("%08x: %s", $offset, $opcodes);
            }
            else {
               # skip lines with no opcode data
               next;
            }
         }

      }
      elsif (length($line) != 0) {
         # comment non blank lines
         $line =~ s/^/# /;
      }

      print STDOUT $line, "\n";
   }
   close $fh;
}

# -----------------------------------------------------------------------------
# Returns the offset found at the start of a given line.
# Params: $line - line from objdump output
# Returns: offset found at the start of the line

sub line_offset($)
{
   my ($line) = @_;
   my $str;

   # get offset of current line
   $str = '0x' . substr($line, 0, 8);
   $str =~ s/ /0/g;
   return oct($str);
}

# -----------------------------------------------------------------------------
# Given the filename of an executable, disassemble it and attempt to
# find the position of jump indexes (switch statements).
# Params:  $filename - name of executable file
# Returns: list of hash objects containing 'end_opcodes', 'num_indexes' and
#           'start_indexes'

sub get_indexed_jumps($)
{
   my ($filename) = @_;
   my ($line, $prev1, $prev2, $prev3, $prev4, $prev5, $ja_line, $cmp_line);
   my ($jmp_indexes, $reg, $num_indexes, $end_opcodes);

   my @jumps = ();

   # perform disassembly
   my $fh = new FileHandle;
   my $cmd = "$OBJDUMP -d -j .text $filename";
   open $fh, "$cmd 2>/dev/null |" or die "couldn't run objdump: $!";

   $prev5 = "";
   $prev4 = "";
   $prev3 = "";
   $prev2 = "";
   $prev1 = "";
   while ($line = <$fh>) {
      chomp($line);
      $prev5 = $prev4;
      $prev4 = $prev3;
      $prev3 = $prev2;
      $prev2 = $prev1;
      $prev1 = $line;

      # Search for something like the following:
      #         cmp    $0xb,%eax
      #         ja     0x8048eb8
      #         jmp    *0x804832c(,%eax,4)
      # Which specifies a jump table of 11 elements starting at
      # 0x804832c.
      #
      if ($prev2 =~ /jmp\s+\*(0x)?([0-9a-f]+)\(,(%...),4\)/) {
         $jmp_indexes = oct('0x' . $2);
         $reg = $3;
         if ($prev3 =~ /mov\s+((0x)?[0-9a-f]+\(%ebp\)),$reg/) {
            $reg = $2;
            $ja_line = $prev4;
            $cmp_line = $prev5;
         }
         else {
            $ja_line = $prev3;
            $cmp_line = $prev4;
         }

         if ($ja_line =~ /ja\s+(0x)?[0-9a-f]+/) {
            if ($cmp_line =~ /cmpl?\s+\$(0x)?([0-9a-f]+),$reg/) {
               $num_indexes = oct('0x' . $2) + 1;
               $end_opcodes = &line_offset($line);
               push @jumps, { end_opcodes => $end_opcodes,
                              num_indexes => $num_indexes,
                              start_indexes => $jmp_indexes };
            }
            else {
               die "cmp expected `$cmp_line'";
            }
         }
         else {
            print $prev3, "\n";
            die "ja expected";
         }
      }
   }
   close $fh;

   return @jumps;
}

############################### Usage Functions ###############################

# -----------------------------------------------------------------------------
# Parses the command line for any specified options.  Sets the appropriate
# option flags if options are specified.  Prints usage info if invalid options
# are given.
# Returns: nothing

sub parse_command_line_for_options()
{
   my ($want_raw)     = 0;
   my ($want_quiet)   = 0;
   my ($want_version) = 0;
   my ($want_help)    = 0;

   &GetOptions("q|quiet"   => \$want_quiet,
               "r|raw"     => \$want_raw,
               "V|version" => \$want_version,
               "h|help"    => \$want_help,
              );

   if ($want_version) {
      print "$0 $VERSION\n";
      exit 0;
   }

   if ($want_help) {
      &usage();
   }

   if ($want_raw) {
      $Raw = 1;
   }

   $Verbose = !$want_quiet;
}

# -----------------------------------------------------------------------------
# Prints a nice usage message to stdout, and then exits.

sub usage()
{
   print <<"_END";

$0 v${VERSION}
A program to generate an initial assembly dump of a binary file.  The
generated file is used as a basis to apply the various decomp filters.

Usage: $0 [options] [file_name]
   filename is the name of the executable file to process.
Options:
    -r, --raw             include raw opcodes in output dump
    -V, --version         outputs version information and exits
    -h, --help            displays this help and exits

_END

   exit 1;
}
