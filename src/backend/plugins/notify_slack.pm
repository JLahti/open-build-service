package notify_slack;

use LWP::UserAgent;
use BSConfig;
use JSON;

use strict;

sub new {
  my $self = {};
  bless $self, shift;
  return $self;
}

sub notify() {
  my ($self, $type, $paramRef ) = @_;

  $type = "UNKNOWN" unless $type;
  my $prefix = $BSConfig::notification_namespace || "OBS";
  $type =  "${prefix}_$type";

  if ($paramRef && $type eq "OBS_BUILD_FAIL" && $paramRef->{'project'} =~ $BSConfig::notification_prj_filter ) {
    $paramRef->{'eventtype'} = $type;
    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(POST => $BSConfig::slack_webhook);
    $req->header('content-type' => 'application/json');
    my $logurl = $BSConfig::obs_ui."/package/live_build_log/".$paramRef->{'project'}."/".$paramRef->{'package'}."/".$paramRef->{'repository'}."/".$paramRef->{'arch'};
    my $msg = "$paramRef->{'project'} $paramRef->{'package'} failed to build $logurl";
    my $pd = "{\"text\": \"$msg\"}";
    $req->content($pd);
    $ua->timeout(10);
    my $resp = $ua->request($req);
  }
}

1;
