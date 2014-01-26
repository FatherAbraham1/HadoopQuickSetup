<?php

/* Pass in by reference! */
function graph_hbaserequestcount_report( &$rrdtool_graph ) 
{
    global $conf,
           $context,
           $range,
           $rrd_dir,
           $size;

    if ($conf['strip_domainname']) {
       $hostname = strip_domainname($GLOBALS['hostname']);
    } else {
       $hostname = $GLOBALS['hostname'];
    }

    $title = 'HBase Regionserver Request count';
    $rrdtool_graph['title'] = $title;
    $rrdtool_graph['vertical-label'] = 'request count';
    $rrdtool_graph['height'] += ($size == 'medium') ? 28 : 0;
    $rrdtool_graph['extras'] = ($conf['graphreport_stats'] == true) ? ' --font LEGEND:7' : '';
    $rrdtool_graph['extras']  .= " --rigid";

    if ( $conf['graphreport_stats'] ) {
        $rrdtool_graph['height'] += ($size == 'medium') ? 16 : 0;
        $rmspace = '     ';
    } else {
        $rmspace = '  ';
    }

    $series = '';

    // RB: Perform some formatting/spacing magic.. tinkered to fit
    //
    $eol1 = '';
    $space1 = '';
    $space2 = '';
    if ($size == 'small') {
       $eol1 = '\\l';
       $space1 = ' ';
       $space2 = '         ';
    } else if ($size == 'medium' || $size == 'default') {
       $eol1 = '';
       $space1 = ' ';
       $space2 = '';
    } else if ($size == 'large') {
       $eol1 = '';
       $space1 = '                 ';
       $space2 = '                 ';
    }

     if(file_exists("$rrd_dir/hbase.regionserver.readRequestsCount.rrd")){
      $series .= "DEF:'readRequestsCount'='${rrd_dir}/hbase.regionserver.readRequestsCount.rrd':'sum':AVERAGE "
              . "'LINE2:readRequestsCount#00FF00:hbase.regionserver.readRequestsCount${rmspace}' ";
     }

    if(file_exists("$rrd_dir/hbase.regionserver.writeRequestsCount.rrd")){
      $series .= "DEF:'writeRequestsCount'='${rrd_dir}/hbase.regionserver.writeRequestsCount.rrd':'sum':AVERAGE "
              . "'LINE2:writeRequestsCount#FF0000:hbase.regionserver.writeRequestsCount${rmspace}' ";
    }
  // If metrics like cpu_user and wio are not present we are likely not collecting them on this
  // host therefore we should not attempt to build anything and will likely end up with a broken
  // image. To avoid that we'll make an empty image
  if ( !file_exists("$rrd_dir/hbase.regionserver.writeRequestsCount.rrd") && !file_exists("$rrd_dir/hbase.regionserver.readRequestsCount.rrd") ) 
    $rrdtool_graph[ 'series' ] = 'HRULE:1#FFCC33:"No matching metrics detected"';   
  else
    $rrdtool_graph[ 'series' ] = $series;

    return $rrdtool_graph;
}

?>
