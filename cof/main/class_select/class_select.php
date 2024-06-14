<?php

function onCreateClassButtons() {
   $class_info = file_get_contents('../../static/classes/class_info.json');
   $class_info = json_decode($class_info, true);
   $class_info = $class_info["class_info"];
   foreach ($class_info as $info) {
       $name = $info["name"];
       echo "<div> <button type='submit' name='class_select'> $name </button></div>";
   }
}
function onCreateSelectedClasses() {

}
?>
<link href="class_select.css" rel="stylesheet">
<html lang="en">
<body>
<div id="classes">
    <?php
    onCreateClassButtons();
    onCreateSelectedClasses();
    ?>
</div>
</body>
</html>
