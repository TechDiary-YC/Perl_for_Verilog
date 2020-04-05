#============================
# Developer: YANCheng
# Mail:      yancheng@tju.edu.cn
# Version:   1.0
# FinishTime:2020/4/5
#============================

#!/usr/bin/perl

use warnings;
sub make_inst { # sub function
open(verilog_file,"@_");
my @lines = ();

while(<verilog_file>){
  push @lines, "$_";
}
my $string = "";
my @input_ports = ();
my @input_width = ();
my @output_regorwire = ();
my @output_ports = ();
my @output_width = ();
my @pm_name = ();
my @pm_val = ();
my $module_name = "";
foreach $string (@lines){
  $string =~ s/\/\/.+\w//g;# delete "//" and latter words
  # module name
  if($string =~ m/^module/){
    $string =~ s/(module)|\W+|\s|\t//g;# delete other words
    $module_name = $string;# module name
  }

  # parameter info
  elsif($string =~ s/parameter//){# find and delete parameter
    $string =~ s/\s|\t|,//g;# delete " " or table 
    if($string =~ m/\/\//){}
    else{
      if(($string =~ m/=/)){
       push @pm_name,$`;
       push @pm_val,$';
      }
    }
  }

  # input info
  elsif($string =~ m/input/){ # lines conclude "input"
    if($` =~ m/\/\//){ # "//"before input
    }
    else{ # input lines fetched
      # delete \s and "input" and "wire" and ","
      $string =~ s/\s|\t|(input)|(wire)|,//g;
      if($string =~ m/\[.+\w\]/){
        push @input_width,$&; # width
        push @input_ports,$'; # ports
      }
      else{
        push @input_width,"\t";# table
        push @input_ports,$string; # ports
      }
    }
  }
  # output info
  elsif($string =~ m/output/){
    if($` =~ m/\/\//){} # "//" before output
    else{ # output lines fetched
      $string =~ s/\s|\t|(output)|,//g;
      if($string =~ s/(reg)|(wire)//){
        push @output_regorwire,$&; 
      }
      else{
        push @output_regorwire,"wire";
      }
      if($string =~ m/\[.+\w\]/){
        push @output_width,$&;
        push @output_ports,$';
      }
      else{
        push @output_width,"\t";
        push @output_ports,$string;
      }
    }   
  }
  else{
  }
}

close(verilog_file);
my @name_pm = ();
my @val_pm = ();
my @comm_pm = ();
my $index = 0;
# parameter name & val
foreach (@pm_name){
  $val_pm[$index]  = "(".$pm_val[$index];
  if($index == 0){#first out
    $name_pm[$index] ="#(.".$_."\r\n";
  }else{#body out
    $name_pm[$index] ="  .".$_."\r\n";
  }
  # commas
  if($index == (scalar @pm_name)-1){
    $comm_pm[$index] = "))\r\n";
  }else{
    $comm_pm[$index] = "),\r\n";
  }
  $index ++;
}
my @ports_name = ();
my @ports_val = ();
my @ports_commas = ();
my $index2 = 0;
# ports
foreach (@input_ports){
  $ports_name[$index2] = "  .".$_."\r\n";
  $ports_val[$index2] = "(".$_;
  $ports_commas[$index2]="),\r\n";
  $index2++;
}
my $index3 = scalar @input_ports;

foreach (@output_ports){
  $ports_name[$index3] = "  .".$_."\r\n";
  $ports_val[$index3] = "(".$_;
  if($index3 == (scalar @input_ports)+(scalar @output_ports)-1){
    $ports_commas[$index3]=") \r\n";# last port
  }
  else{
    $ports_commas[$index3]="),\r\n";
  }
  $index3++;
}
my $inst_name  = "inst_".$module_name."(";
my @name_array = ($module_name,@name_pm,$inst_name,@ports_name,");");
my @val_array  = ("",@val_pm,"\r\n",@ports_val,"");
my @comm_array = ("\r\n",@comm_pm,"\r\n",@ports_commas,"\r\n");
my $name = "";
my $val  = "";
my $comma  = "";

open(MYFILE,"+>>./file.inst");

$~ = MYFILE;

format MYFILE = 
@<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<@<<<
$name,$val,$comma
.
my $i = 0;
foreach (@name_array){
  $name = $name_array[$i];
  $val  = $val_array[$i];
  $comma  = $comm_array[$i];
  $i ++;
  write MYFILE;
}
}
# find .v file
$dir = "./*.v";
@files = glob( $dir );
 
foreach (@files ){
   make_inst($_);
}
close MYFILE;
