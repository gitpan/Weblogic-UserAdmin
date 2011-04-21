#!/usr/bin/perl


use Weblogic::UserAdmin;
use List::Compare;
use Getopt::Long;
use strict;


=head1 NAME

energy_user.pl - Administration Functions For Energy Automated

=head1 SYNOPSIS

  energy_user.pl [OPTION] --server [weblogicserver] --port [port]

=head1 DESCRIPTION

  Perform add delete  etc operations on users in weblogic.

  --add --username [user] --password [password] 
        add a single user to the named weblogic server. 
        The weblogic group is selected based on the group with the smallest number of users
  
  --del --username [user] 
        del a single user from the named weblogic server. 
        The user is removed from the any groups automatically.
        
  --exist --username [user] 
        Does the user exist?
        
  --except [filename] --confirm
  		delete all users except those contained in the linefeed delimited file [filename]  
  
  --group [groupname] --username [username]
        add the name user to the named group.

=head1 EXAMPLES


  Remove the testadd user from the energytest3 server
    energy_user.pl --del --server energytest3 --port 11530 --user testadd

  Add a user called dpeters4 to the energytest3 server
	energy_user.pl --del --user dpeters4 --password uknowit --server energytest3 --port 11530
	
  Does a user exist?
    energy_user.pl --exist --user dpeters --server energytest3 --port 11530 	

=head1 AUTHOR

    David Peters
    CPAN ID: DAVIDP
    David.Peters@EssentialEnergy.com.au



=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

man Energy::UserAdmin

perl(1).

=cut

#################### main pod documentation end ###################





my $server;
my $port;
my $user;
my $password;
my $add;
my $delete;
my $group;
my $help=0;
my $exist;
my $except;
my $confirm;




GetOptions(
			'add'=>\$add,
			'del'=>\$delete,
			'server=s'=>\$server,
			'port=i'=>\$port, 
			'user=s'=>\$user, 
			'password=s'=>\$password,
			'group=s'=>\$group,
			'exist'=>\$exist,
			'except=s'=>\$except,
			'confirm'=>\$confirm,
			'help'=>\$help
			);

if($help) {
	print "[--add | --del | --exist | --except filename | --group user] 
	--server servername --port portname --user username --password password\n";
	exit;
}

my $energy = Weblogic::UserAdmin->new({
				console=>"http://$server", 
				port => $port,
				username => "system",
				password => "narcolepsy",
			});
	
	

if($exist) {
	if($energy->user_exist($user)) {
		print "User Exists\n";
	} else {
		print "User does not exist\n";
	};
	
	exit 0;	
}


###
### 
### Add USer
###
###
if($add) {
	
	if($energy->user_exist($user)) {
		print "User Already Exists\n";
		exit 1;
	};

	my $lowestgroup=0;
	my $lowest;
	for( my $group=1; $group<=6;$group++) {
		my $count = scalar $energy->group_list({group=>"ce".$group }) . "\n";
		if($count < $lowest || $lowest == 0 ) {
			$lowest = $count;
			$lowestgroup = $group;
		}
		
			
	}
	print "Adding to group ce" . $lowestgroup . "\n";
	$energy->user_add({user=>$user, password=>$password});
	$energy->user_add_group({user=>$user, group=>"ce".$lowestgroup});
	
	
	
}


###
###
### add group
###
###
if($group ne "" ) {
	$energy->user_add_group({user=>$user, group=>$group});
}



###
###
### delete user
###
###

if($delete) {
	user_del();
}


###
###
### Remove all users except those provided in a file
###
###
###
if($except && $confirm ) {
	open(FH,"<",$except) || die "Couldnt open input file.";	
	my $users;
	my $willexit;
		while(<FH>) {
		chomp;
		$users->{$_} = 1;
		$user = lc $_;	
		
		if(!$energy->user_exist($user)) {
			print "$user: User Doesn't Exist\n";
			$willexit = 1;
			exit 1;
		};
		
	}
	close FH;
	$willexit && exit 1;
	
	print "Removing Users\n";
	my @users = $energy->users();
	foreach (@users) {
		if($users->{$_} != 1 ) {
			print "Removing " . $_ . "\n";
			$user = $_;
			$energy->user_del({user=>$user});
			
		}
	}
}




sub user_del {
	
	if($energy->user_exist($user)) {
		$energy->user_del({user=>$user});
	} else {	
		print "User Doesnt Exist\n";
		exit 1;
	}
}










