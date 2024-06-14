<?php
$play = isset($_GET['play']);
if ($play) {onPlayPressed();}

function onPlayPressed() {

}

?>
<link href="main_menu.css" rel="stylesheet">
<html lang="en">
<body>
<div id="centerdiv">
    <h1 id="main_menu_title"> Conquest of Fuyan </h1>
    <form action="../class_select/class_select.php">
        <button type="submit" value="play"> Play </button> <br>
    </form>
        <button> Continue </button>
</div>
</body>
</html>