#!/usr/bin/env perl

use strict;

## BEGIN BOILERPLATE VARS  - signature of the sufficiently lazy
my $progName = `basename $0`;
chomp($progName);
my $now = `date "+%Y%m%d%H%M%S"`;
chomp $now;
my @origArgs = map { sprintf("\x27%s\x27", $_ );} @ARGV;
my $version  = "0.001.001";
##   debugging stuff
sub nobuff {
	## prevent output buffering, leave STDOUT as default
	select(STDERR); $|=1;   # Autoflush STDERR.
	select(STDOUT); $|=1;   # Autoflush STDOUT.
}
my $nobugA  = 1;
my $nobugB  = 0;
my $verbose = 0;

## ENDOF BOILERPLATE VARS


my $list = 0;
my $url = "https://www1.ncdc.noaa.gov/pub/data/uscrn/products/hourly02";

sub usage {
    my $err = shift;

    if ($err) { print "\n$err\n"; }

    print "
Usage: $progName  [-v -h -l ]  firstYear lastYear Location - get year of hourly weather data

  gets data files from '$url'

  -l : list locations
  -h: help
  -v: verbose/debug

  ";
    exit 99;
}

my %locsToFile = (
  "SD_Buffalo" => "CRNH0203-2018-SD_Buffalo_13_ESE.txt",
  "KY_Bowling_Green" => "CRNH0203-2018-KY_Bowling_Green_21_NNE.txt",
  "KS_Oakley" => "CRNH0203-2018-KS_Oakley_19_SSW.txt",
  "AK_Ivotuk" => "CRNH0203-2018-AK_Ivotuk_1_NNE.txt",
  "CA_Santa_Barbara" => "CRNH0203-2018-CA_Santa_Barbara_11_W.txt",
  "IL_Shabbona" => "CRNH0203-2018-IL_Shabbona_5_NNE.txt",
  "AZ_Tucson" => "CRNH0203-2018-AZ_Tucson_11_W.txt",
  "OR_John_Day" => "CRNH0203-2018-OR_John_Day_35_WNW.txt",
  "MT_Lewistown" => "CRNH0203-2018-MT_Lewistown_42_WSW.txt",
  "HI_Mauna_Loa" => "CRNH0203-2018-HI_Mauna_Loa_5_NNE.txt",
  "AK_Red_Dog_Mine" => "CRNH0203-2018-AK_Red_Dog_Mine_3_SSW.txt",
  "TX_Palestine" => "CRNH0203-2018-TX_Palestine_6_WNW.txt",
  "AK_Yakutat" => "CRNH0203-2018-AK_Yakutat_3_SSE.txt",
  "IL_Champaign" => "CRNH0203-2018-IL_Champaign_9_SW.txt",
  "FL_Titusville" => "CRNH0203-2018-FL_Titusville_7_E.txt",
  "ND_Northgate" => "CRNH0203-2018-ND_Northgate_5_ESE.txt",
  "WA_Quinault" => "CRNH0203-2018-WA_Quinault_4_NE.txt",
  "CO_Cortez" => "CRNH0203-2018-CO_Cortez_8_SE.txt",
  "AK_Toolik_Lake" => "CRNH0203-2018-AK_Toolik_Lake_5_ENE.txt",
  "CO_Nunn" => "CRNH0203-2018-CO_Nunn_7_NNE.txt",
  "CA_Yosemite_Village" => "CRNH0203-2018-CA_Yosemite_Village_12_W.txt",
  "AK_Selawik" => "CRNH0203-2018-AK_Selawik_28_E.txt",
  "ND_Medora" => "CRNH0203-2018-ND_Medora_7_E.txt",
  "CA_Bodega" => "CRNH0203-2018-CA_Bodega_6_WSW.txt",
  "CA_Fallbrook" => "CRNH0203-2018-CA_Fallbrook_5_NE.txt",
  "MS_Newton" => "CRNH0203-2018-MS_Newton_5_ENE.txt",
  "AL_Scottsboro" => "CRNH0203-2018-AL_Scottsboro_2_NE.txt",
  "KS_Manhattan" => "CRNH0203-2018-KS_Manhattan_6_SSW.txt",
  "ND_Jamestown" => "CRNH0203-2018-ND_Jamestown_38_WSW.txt",
  "IN_Bedford" => "CRNH0203-2018-IN_Bedford_5_WNW.txt",
  "GA_Newton" => "CRNH0203-2018-GA_Newton_11_SW.txt",
  "AK_Sitka" => "CRNH0203-2018-AK_Sitka_1_NE.txt",
  "AK_Kenai" => "CRNH0203-2018-AK_Kenai_29_ENE.txt",
  "WY_Moose" => "CRNH0203-2018-WY_Moose_1_NNE.txt",
  "PA_Avondale" => "CRNH0203-2018-PA_Avondale_2_N.txt",
  "AL_Clanton" => "CRNH0203-2018-AL_Clanton_2_NE.txt",
  "AZ_Elgin" => "CRNH0203-2018-AZ_Elgin_5_S.txt",
  "OK_Stillwater" => "CRNH0203-2018-OK_Stillwater_2_W.txt",
  "FL_Everglades_City" => "CRNH0203-2018-FL_Everglades_City_5_NE.txt",
  "TX_Muleshoe" => "CRNH0203-2018-TX_Muleshoe_19_S.txt",
  "GA_Watkinsville" => "CRNH0203-2018-GA_Watkinsville_5_SSE.txt",
  "MT_St._Mary" => "CRNH0203-2018-MT_St._Mary_1_SSW.txt",
  "CO_La_Junta" => "CRNH0203-2018-CO_La_Junta_17_WSW.txt",
  "LA_Lafayette" => "CRNH0203-2018-LA_Lafayette_13_SE.txt",
  "NM_Los_Alamos" => "CRNH0203-2018-NM_Los_Alamos_13_W.txt",
  "AL_Greensboro" => "CRNH0203-2018-AL_Greensboro_2_WNW.txt",
  "SD_Pierre" => "CRNH0203-2018-SD_Pierre_24_S.txt",
  "AL_Russellville" => "CRNH0203-2018-AL_Russellville_4_SSE.txt",
  "TX_Port_Aransas" => "CRNH0203-2018-TX_Port_Aransas_32_NNE.txt",
  "TX_Monahans" => "CRNH0203-2018-TX_Monahans_6_ENE.txt",
  "AL_Valley_Head" => "CRNH0203-2018-AL_Valley_Head_1_SSW.txt",
  "OK_Goodwell" => "CRNH0203-2018-OK_Goodwell_2_SE.txt",
  "VA_Cape_Charles" => "CRNH0203-2018-VA_Cape_Charles_5_ENE.txt",
  "AK_Denali" => "CRNH0203-2018-AK_Denali_27_N.txt",
  "MI_Chatham" => "CRNH0203-2018-MI_Chatham_1_SE.txt",
  "ID_Murphy" => "CRNH0203-2018-ID_Murphy_10_W.txt",
  "NV_Baker" => "CRNH0203-2018-NV_Baker_5_W.txt",
  "CA_Stovepipe_Wells" => "CRNH0203-2018-CA_Stovepipe_Wells_1_SW.txt",
  "UT_Brigham_City" => "CRNH0203-2018-UT_Brigham_City_28_WNW.txt",
  "GA_Newton" => "CRNH0203-2018-GA_Newton_8_W.txt",
  "RI_Kingston" => "CRNH0203-2018-RI_Kingston_1_W.txt",
  "AK_Cordova" => "CRNH0203-2018-AK_Cordova_14_ESE.txt",
  "AK_Sand_Point" => "CRNH0203-2018-AK_Sand_Point_1_ENE.txt",
  "NY_Millbrook" => "CRNH0203-2018-NY_Millbrook_3_W.txt",
  "AR_Batesville" => "CRNH0203-2018-AR_Batesville_8_WNW.txt",
  "AK_Utqiagvik" => "CRNH0203-2018-AK_Utqiagvik_formerly_Barrow_4_ENE.txt",
  "GA_Brunswick" => "CRNH0203-2018-GA_Brunswick_23_S.txt",
  "OR_Coos_Bay" => "CRNH0203-2018-OR_Coos_Bay_8_SW.txt",
  "NM_Socorro" => "CRNH0203-2018-NM_Socorro_20_N.txt",
  "NC_Durham" => "CRNH0203-2018-NC_Durham_11_W.txt",
  "NM_Las_Cruces" => "CRNH0203-2018-NM_Las_Cruces_20_N.txt",
  "AK_Fairbanks" => "CRNH0203-2018-AK_Fairbanks_11_NE.txt",
  "MI_Gaylord" => "CRNH0203-2018-MI_Gaylord_9_SSW.txt",
  "NE_Lincoln" => "CRNH0203-2018-NE_Lincoln_11_SW.txt",
  "AK_Deadhorse" => "CRNH0203-2018-AK_Deadhorse_3_S.txt",
  "AZ_Williams" => "CRNH0203-2018-AZ_Williams_35_NNW.txt",
  "CO_Boulder" => "CRNH0203-2018-CO_Boulder_14_W.txt",
  "VA_Charlottesville" => "CRNH0203-2018-VA_Charlottesville_2_SSE.txt",
  "AK_Tok" => "CRNH0203-2018-AK_Tok_70_SE.txt",
  "AL_Courtland" => "CRNH0203-2018-AL_Courtland_2_WSW.txt",
  "AK_Glennallen" => "CRNH0203-2018-AK_Glennallen_64_N.txt",
  "AK_Port_Alsworth" => "CRNH0203-2018-AK_Port_Alsworth_1_SW.txt",
  "SD_Sioux_Falls" => "CRNH0203-2018-SD_Sioux_Falls_14_NNE.txt",
  "AZ_Yuma" => "CRNH0203-2018-AZ_Yuma_27_ENE.txt",
  "AK_Metlakatla" => "CRNH0203-2018-AK_Metlakatla_6_S.txt",
  "CO_Dinosaur" => "CRNH0203-2018-CO_Dinosaur_2_E.txt",
  "TN_Crossville" => "CRNH0203-2018-TN_Crossville_7_NW.txt",
  "SC_McClellanville" => "CRNH0203-2018-SC_McClellanville_7_NE.txt",
  "SA_Tiksi" => "CRNH0203-2018-SA_Tiksi_4_SSE.txt",
  "MO_Joplin" => "CRNH0203-2018-MO_Joplin_24_N.txt",
  "NH_Durham" => "CRNH0203-2018-NH_Durham_2_SSW.txt",
  "MS_Holly_Springs" => "CRNH0203-2018-MS_Holly_Springs_4_N.txt",
  "RI_Kingston" => "CRNH0203-2018-RI_Kingston_1_NW.txt",
  "AL_Thomasville" => "CRNH0203-2018-AL_Thomasville_2_S.txt",
  "MN_Sandstone" => "CRNH0203-2018-MN_Sandstone_6_W.txt",
  "OR_Corvallis" => "CRNH0203-2018-OR_Corvallis_10_SSW.txt",
  "CA_Redding" => "CRNH0203-2018-CA_Redding_12_WNW.txt",
  "TX_Panther_Junction" => "CRNH0203-2018-TX_Panther_Junction_2_N.txt",
  "ID_Arco" => "CRNH0203-2018-ID_Arco_17_SW.txt",
  "TX_Austin" => "CRNH0203-2018-TX_Austin_33_NW.txt",
  "MN_Goodridge" => "CRNH0203-2018-MN_Goodridge_12_NNW.txt",
  "NE_Whitman" => "CRNH0203-2018-NE_Whitman_5_ENE.txt",
  "AK_Gustavus" => "CRNH0203-2018-AK_Gustavus_2_NE.txt",
  "MO_Chillicothe" => "CRNH0203-2018-MO_Chillicothe_22_ENE.txt",
  "MT_Wolf_Point" => "CRNH0203-2018-MT_Wolf_Point_29_ENE.txt",
  "LA_Monroe" => "CRNH0203-2018-LA_Monroe_26_N.txt",
  "SD_Aberdeen" => "CRNH0203-2018-SD_Aberdeen_35_WNW.txt",
  "NH_Durham" => "CRNH0203-2018-NH_Durham_2_N.txt",
  "TX_Edinburg" => "CRNH0203-2018-TX_Edinburg_17_NNE.txt",
  "AL_Selma" => "CRNH0203-2018-AL_Selma_6_SSE.txt",
  "NE_Lincoln" => "CRNH0203-2018-NE_Lincoln_8_ENE.txt",
  "AL_Selma" => "CRNH0203-2018-AL_Selma_13_WNW.txt",
  "WI_Necedah" => "CRNH0203-2018-WI_Necedah_5_WNW.txt",
  "NV_Mercury" => "CRNH0203-2018-NV_Mercury_3_SSW.txt",
  "CO_Montrose" => "CRNH0203-2018-CO_Montrose_11_ENE.txt",
  "OH_Wooster" => "CRNH0203-2018-OH_Wooster_3_SSE.txt",
  "NY_Ithaca" => "CRNH0203-2018-NY_Ithaca_13_E.txt",
  "SC_Blackville" => "CRNH0203-2018-SC_Blackville_3_W.txt",
  "CA_Merced" => "CRNH0203-2018-CA_Merced_23_WSW.txt",
  "MT_Dillon" => "CRNH0203-2018-MT_Dillon_18_WSW.txt",
  "AK_Ruby" => "CRNH0203-2018-AK_Ruby_44_ESE.txt",
  "HI_Hilo" => "CRNH0203-2018-HI_Hilo_5_S.txt",
  "AL_Northport" => "CRNH0203-2018-AL_Northport_2_S.txt",
  "NV_Denio" => "CRNH0203-2018-NV_Denio_52_WSW.txt",
  "AL_Fairhope" => "CRNH0203-2018-AL_Fairhope_3_NE.txt",
  "WY_Sundance" => "CRNH0203-2018-WY_Sundance_8_NNW.txt",
  "AL_Gadsden" => "CRNH0203-2018-AL_Gadsden_19_N.txt",
  "IA_Des_Moines" => "CRNH0203-2018-IA_Des_Moines_17_E.txt",
  "ME_Old_Town" => "CRNH0203-2018-ME_Old_Town_2_W.txt",
  "WA_Darrington" => "CRNH0203-2018-WA_Darrington_21_NNE.txt",
  "AL_Cullman" => "CRNH0203-2018-AL_Cullman_3_ENE.txt",
  "AL_Muscle_Shoals" => "CRNH0203-2018-AL_Muscle_Shoals_2_N.txt",
  "WY_Lander" => "CRNH0203-2018-WY_Lander_11_SSE.txt",
  "AL_Talladega" => "CRNH0203-2018-AL_Talladega_10_NNE.txt",
  "WV_Elkins" => "CRNH0203-2018-WV_Elkins_21_ENE.txt",
  "ME_Limestone" => "CRNH0203-2018-ME_Limestone_4_NNW.txt",
  "WA_Spokane" => "CRNH0203-2018-WA_Spokane_17_SSW.txt",
  "AL_Troy" => "CRNH0203-2018-AL_Troy_2_W.txt",
  "OR_Riley" => "CRNH0203-2018-OR_Riley_10_WSW.txt",
  "OK_Stillwater" => "CRNH0203-2018-OK_Stillwater_5_WNW.txt",
  "AK_King_Salmon" => "CRNH0203-2018-AK_King_Salmon_42_SE.txt",
  "NC_Asheville" => "CRNH0203-2018-NC_Asheville_8_SSW.txt",
  "MT_Wolf_Point" => "CRNH0203-2018-MT_Wolf_Point_34_NE.txt",
  "AL_Brewton" => "CRNH0203-2018-AL_Brewton_3_NNE.txt",
  "AK_St._Paul" => "CRNH0203-2018-AK_St._Paul_4_NE.txt",
  "MO_Salem" => "CRNH0203-2018-MO_Salem_10_W.txt",
  "KY_Versailles" => "CRNH0203-2018-KY_Versailles_3_NNW.txt",
  "UT_Torrey" => "CRNH0203-2018-UT_Torrey_7_E.txt",
  "FL_Sebring" => "CRNH0203-2018-FL_Sebring_23_SSE.txt",
  "NC_Asheville" => "CRNH0203-2018-NC_Asheville_13_S.txt",
  "NE_Harrison" => "CRNH0203-2018-NE_Harrison_20_SSE.txt",
  "AL_Gainesville" => "CRNH0203-2018-AL_Gainesville_2_NE.txt",
  "TX_Bronte" => "CRNH0203-2018-TX_Bronte_11_NNE.txt",
  "ON_Egbert" => "CRNH0203-2018-ON_Egbert_1_W.txt",
  "AL_Highland_Home" => "CRNH0203-2018-AL_Highland_Home_2_S.txt",
  "OK_Goodwell" => "CRNH0203-2018-OK_Goodwell_2_E.txt"
);


my @locs =  sort(keys %locsToFile );

## parse args1
for ( ; $ARGV[0] =~ m/^-(h|v|l)$/ ; ) {
    if ( "-h" eq $ARGV[0] ) { usage(); exit 99; }
    if ( "-v" eq $ARGV[0] ) { ++$verbose; }
    if ( "-l" eq $ARGV[0] ) {
      print "" . join("\n", @locs) . "\n";
      exit 0;
    }
    shift;
}

$nobugB = ( $verbose < 1 );
$nobugA = ( $verbose < 2 );
nobuff();

my ($start, $stop, $loc) = (@ARGV);

my $fpat =  $locsToFile{$loc};
if (! $fpat ) {
  usage "Error:  location: $loc  not found, try -l\n";
} else {
  my $y = $start;
  for (; $y <= $stop; ++$y) {
    my $fn = ($fpat =~ s/2018/$y/gr);
    system("curl ${url}/$y/$fn > $fn 2> /dev/null");
    print "year=$y, file=$fn,  " .  ((-f $fn) ? "ok" : "failed") . "\n";
  }
}
