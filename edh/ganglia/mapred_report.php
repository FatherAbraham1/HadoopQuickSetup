<?php

/* Pass in by reference! */
function graph_mapred_report( &$rrdtool_graph ) 
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

    $title = 'Mapreduce Slots';
    $rrdtool_graph['title'] = $title;
    $rrdtool_graph['vertical-label'] = 'Slots';
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


    if(file_exists("$rrd_dir/mapred.tasktracker.maps_running.rrd")){
      $series .= "DEF:'maps_running'='${rrd_dir}/mapred.tasktracker.maps_running.rrd':'sum':AVERAGE "
              . "'LINE2:maps_running#FF0000:mapred.tasktracker.maps_running${rmspace}' ";
    }
    if(file_exists("$rrd_dir/mapred.tasktracker.reduces_running.rrd")){

      $series .= "DEF:'reduces_running'='${rrd_dir}/mapred.tasktracker.reduces_running.rrd':'sum':AVERAGE "
              . "'LINE2:reduces_running#00FF00:mapred.tasktracker.reduces_running${rmspace}' ";
    }
    if(file_exists("$rrd_dir/mapred.tasktracker.mapTaskSlots.rrd")){
      $series .= "'DEF:mapTaskSlots=${rrd_dir}/mapred.tasktracker.mapTaskSlots.rrd:sum:AVERAGE' "
              . "'LINE2:mapTaskSlots#2030F4:mapred.tasktracker.mapTaskSlots${rmspace}' ";
    }

    if(file_exists("$rrd_dir/mapred.tasktracker.reduceTaskSlots.rrd")){
      $series .= "'DEF:reduceTaskSlots=${rrd_dir}/mapred.tasktracker.reduceTaskSlots.rrd:sum:AVERAGE' "
              . "'LINE2:reduceTaskSlots#9900CC:mapred.tasktracker.reduceTaskSlots${rmspace}'" ;
}
  // If metrics like cpu_user and wio are not present we are likely not collecting them on this
  // host therefore we should not attempt to build anything and will likely end up with a broken
  // image. To avoid that we'll make an empty image
  if ( !file_exists("$rrd_dir/mapred.tasktracker.maps_running.rrd") && !file_exists("$rrd_dir/mapred.tasktracker.reduces_running.rrd") && !file_exists("$rrd_dir/mapred.tasktracker.mapTaskSlots.rrd") && !file_exists("$rrd_dir/mapred.tasktracker.reduceTaskSlots.rrd") ) 
    $rrdtool_graph[ 'series' ] = 'HRULE:1#FFCC33:"No matching metrics detected"';   
  else
    $rrdtool_graph[ 'series' ] = $series;

    return $rrdtool_graph;
}

?>
