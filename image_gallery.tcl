#!/usr/bin/env tclsh

# Usage:
# tclsh image_gallery.tcl /path/to/folder/that/contains/images

set gal_dir_name "gallery"
set thumb_width 240
set big_width 800

set path [lindex $argv 0]

if { [file exists $path] == 0 } {
  puts "The folder $path was not found."
  exit
}

# Resize an image to the given with, and place it under the given directory
# And automagically orient (rotate) an image created by a digital camera, with -auto-orient: 
proc resize {img_file width destination_dir} {
  set img_file_destination "$destination_dir/[file tail $img_file]"
  exec convert $img_file -auto-orient -resize $width $img_file_destination
}

# Ensures there is a sub directory named gallery/ under $path
proc create_gallery_dir_in {path} {
  global gal_dir_name
  if { [file exists "$path/$gal_dir_name"] == 0 } {
    file mkdir "$path/$gal_dir_name"
  }
  if { [file exists "$path/$gal_dir_name/big"] == 0 } {
    file mkdir "$path/$gal_dir_name/big"
  }
  if { [file exists "$path/$gal_dir_name/thumb"] == 0 } {
    file mkdir "$path/$gal_dir_name/thumb"
  }
}

set img_files {}

# Resize the images and place them in the right folders
foreach img_file [glob -nocomplain -directory $path "*.{JPG, jpg}"] {
  # puts $img_file
  lappend img_files $img_file
  # create gallery/ directory
  create_gallery_dir_in $path
  # resize the image and store it in gallery/ directory
  resize $img_file $thumb_width "$path/$gal_dir_name/thumb"
  resize $img_file $big_width "$path/$gal_dir_name/big"
}

set img_table "<html>
<head>
<title>Photos</title>
</head>
<body>
<h1>Photos</h1>
<table><tr>"

# Create an HTML file
for {set i 0} {$i < [llength $img_files]} {incr i} {
  set img_file [lindex $img_files $i]
  set img_file_name [file tail $img_file]
  puts $img_file
  set img_table "$img_table<td><a href='$gal_dir_name/big/$img_file_name'><img src='$gal_dir_name/thumb/$img_file_name' /></a></td>"
  if { [expr ($i+1) % 4] == 0 } {
    set img_table "$img_table</tr><tr>"
  }
}

set img_table "$img_table</tr></table>
</body>
</html>"
# write the HTML file
set fp [open "$path/index.html" w]
puts $fp $img_table



