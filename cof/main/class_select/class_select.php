<?php
include_once('../helper.php');
$mysqli = onAccessDatabase();
onCreateTables($mysqli);

$class_select = isset($_GET['class_select']);
$remove_class = isset($_GET['remove_class']);
$main_menu = isset($_GET['main_menu']);
$play = isset($_GET['play']);
if ($class_select) {onClassSelected($mysqli);}
if ($remove_class) {onClassRemoved($mysqli);}
if ($play) {onPlayPressed($mysqli);}
if ($class_select or $remove_class) {
    header("Location: http://$_SERVER[HTTP_HOST]/cof/main/class_select/class_select.php");
}
elseif ($main_menu) {
    header("Location: http://$_SERVER[HTTP_HOST]/cof/main/main_menu/main_menu.php");
}
function onPlayPressed($mysqli) {
    $heroes = getSelectedClassIds($mysqli);
    foreach ($heroes as $hero_info) {
        $class_info = getClassInfo($hero_info);
        $id = $class_info['id'];
        $att = $class_info['att'];
        $hp = $class_info['hp'];
        $mana = $class_info['mana'];
        $update_query = "UPDATE SavesClasses SET max_att='$att', max_hp='$hp', max_mana='$mana' WHERE save_id = 1 AND class_id='$id'";
        $mysqli -> query($update_query);
    }

    $dq = "DELETE FROM Saves";
    $mysqli -> query($dq);

    $iq = "INSERT INTO Saves(save_id, level_id) VALUES (1, 1)";
    $mysqli -> query($iq);
    header("Location: http://$_SERVER[HTTP_HOST]/cof/main/world_map/world_map.php");
}
function onCreateTables($mysqli) {
//    $sq = "DROP TABLE IF EXISTS Saves";
//    $mysqli -> query($sq);
    $create_saves_query = "CREATE TABLE IF NOT EXISTS Saves(
        save_id INT NOT NULL AUTO_INCREMENT,
        level_id INT NOT NULL DEFAULT '1',
        PRIMARY KEY (save_id))";
    # in_map oscillates between 0 and 1 depending on if you're in level or not

//    $dq = "DROP TABLE IF EXISTS SavesClasses";
//    $mysqli -> query($dq);
    $create_saves_classes_query = "CREATE TABLE IF NOT EXISTS SavesClasses(
    save_id INT NOT NULL,
    class_id INT NOT NULL,
    att INT,
    hp INT,
    mana INT,
    max_hp INT,
    max_att INT,
    max_mana INT,
    level_id INT DEFAULT '1',
    PRIMARY KEY (save_id, class_id))";

    $mysqli -> query($create_saves_query);
    $mysqli -> query($create_saves_classes_query);
}
function onAccessDatabase(): mysqli
{
    //mysqli_report(MYSQLI_REPORT_OFF);
    $dbhost = 'localhost';
    $dbuser = 'witold';
    $dbpass = 'witold';
    $dbname = 's32007';
    return new mysqli($dbhost, $dbuser, $dbpass, $dbname);
}
function onCreateClassButtons($mysqli): void {
    $disabled_classes = getSelectedClassIds($mysqli);
    $size = sizeof($disabled_classes);
    foreach ($GLOBALS['classes_info'] as $info) {
        $name = $info["name"];
        $id = $info["id"];

        $is_disabled = (in_array($id, $disabled_classes) or $size == 4);
        if ($is_disabled) {$is_disabled = 'class=btn_disabled disabled';}
        else {$is_disabled = 'class=btn_regular';}

        echo "<div> <button type='submit' name='class_select' value='$id' $is_disabled>
        $name</button> <img src='../../static/class_sprites/front/$id.png' alt='Front Sprite'></div>";
       }
}

function onClassSelected($mysqli) {
    print_r(sizeof(getSelectedClassIds($mysqli)));
    if (sizeof(getSelectedClassIds($mysqli)) < $GLOBALS['MAX_CLASS_COUNT']){
        $class_id = $_GET['class_select'];
        $insert_query = "INSERT INTO SavesClasses(class_id, save_id) VALUES ('$class_id', 1)";
        $mysqli->query($insert_query);
    }
}

function onCreateSelectedClasses($mysqli) {
    $class_ids = getSelectedClassIds($mysqli);

    if (sizeof($class_ids) > 0) {
        echo "<div id='selected_classes'>";
    }
    foreach ($class_ids as $id) {
        $name = getClassInfo($id)['name'];
        echo "<div><button type='submit' name='remove_class' value='$id' class='large_button'> $name </button></div>";
    }
    echo "</div>";
    if (sizeof($class_ids) == 4) {
        echo "<button type='submit' class='bottom_button' name='play'> Play </button>";
    }
}

function onClassRemoved($mysqli) {
    $class_id = $_GET['remove_class'];
    $delete_query = "DELETE FROM SavesClasses WHERE class_id = '$class_id' AND save_id = '1'";
    $mysqli->query($delete_query);
}

function onCreateClassesHeader($mysqli) {
   $classes = getSelectedClassIds($mysqli);
   if (sizeof($classes) > 0) {echo '<h1> Press below to remove a class (MAX = 4) </h1>';}
   else {echo '<h1> Press above to add a class (MAX = 4) </h1>';}
}
?>
<link href="class_select.css" rel="stylesheet">
<html lang="en">
<body>
<form action="class_select.php">
    <div id="classes">
    <?php onCreateClassButtons($mysqli); ?>
    </div>

    <?php onCreateClassesHeader($mysqli) ?>
    <div id="bottom_side">
        <button type="submit" class="bottom_button" name="main_menu"> Main Menu </button>
        <?php onCreateSelectedClasses($mysqli); ?>
    </div>
</form>
</body>
</html>
