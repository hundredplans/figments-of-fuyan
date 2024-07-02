<?php
include_once('../helper.php');
$mysqli = onAccessDatabase();
onRefreshHeroStats($mysqli);
onCreateLevelTable($mysqli);
onDestroyMovesTables($mysqli);
$main_menu = isset($_GET['main_menu']);
$enter_level = isset($_GET['enter_level']);
if ($main_menu) {
    header("Location: http://$_SERVER[HTTP_HOST]/cof/main/main_menu/main_menu.php");
}

elseif ($enter_level) {
    onEnterLevel($mysqli);
}

function onDestroyMovesTables($mysqli) {
    $dq = "DROP TABLE IF EXISTS EnemyMoves";
    $mysqli->query($dq);

    $_dq = "DROP TABLE IF EXISTS AllyMoves";
    $mysqli -> query($_dq);
}
function onCreateLevelTable($mysqli) {
//    $dq = "DROP TABLE Enemies";
//    $mysqli -> query($dq);
    $cq = "CREATE TABLE IF NOT EXISTS Enemies (
        battle_id INT NOT NULL AUTO_INCREMENT,
        enemy_id INT,
        att INT,
        hp INT,
        max_att INT,
        max_hp INT,
        has_moved INT DEFAULT('0'),
        PRIMARY KEY (battle_id))";
    $mysqli -> query($cq);
}
function onEnterLevel($mysqli) {
    $dq = "DELETE FROM Enemies";
    $mysqli -> query($dq);
    $level_info = getLevelInfo($_GET['enter_level']);
    foreach ($level_info['enemies'] as $enemy_id) {
        $enemy_info = getEnemyInfo($enemy_id);
        $max_att = $enemy_info['att'];
        $max_hp = $enemy_info['hp'];
        $id = $enemy_info['id'];
        $uq = "INSERT INTO Enemies(enemy_id, max_att, max_hp, att, hp) VALUES ('$id', '$max_att', '$max_hp', '$max_att', '$max_hp')";
        $mysqli -> query($uq);
    }
    header("Location: http://$_SERVER[HTTP_HOST]/cof/main/level/level.php");
}
function onRefreshHeroStats($mysqli) {
    $heroes = getHeroesInfo($mysqli);
    foreach ($heroes as $hero) {
        $id = $hero['class_id'];
        $max_att = $hero['max_att'];
        $max_hp = $hero['max_hp'];
        $max_mana = $hero['max_mana'];
        $uq = "UPDATE SavesClasses SET att='$max_att', hp='$max_hp', mana='$max_mana' WHERE save_id = '1' AND class_id='$id'";
        $mysqli->query($uq);
    }
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
function onCreateClasses($mysqli) {
    $heroes = getHeroesInfo($mysqli);
    foreach ($heroes as $info) {
        $id = $info['class_id'];
        $att = $info['att'];
        $hp = $info['hp'];
        $mana = $info['mana'];
        echo "
        <div class='hero_info'>
            <div class='hero_info_left'>
                <img src='../../static/class_sprites/front/$id.png' alt='Hero'>
            </div>
        ";
        echo onCreateStats($att, $hp, $mana);
        echo "<div class='level_div'><text>Lvl 1</text></div></div>";
    }
    echo "<div> <button type='submit' name='main_menu' class='large_button'> Main Menu </button></div>";
}

function onLoadMapImage($mysqli) {
    $level_id = onLoadLevelID($mysqli);
    echo "<img id='world_map_img' src='world_map$level_id.png' alt='World Map $level_id'>";
}

?>

<link href="world_map.css" rel="stylesheet">
<link href="../helper.css" rel="stylesheet">
<html lang="en">
<body>
<form action="world_map.php">
    <div id="main">
        <div id="selected_heroes">
            <h1> Heroes </h1>
            <div id="heroes_info">
                <?php onCreateClasses($mysqli); ?>
            </div>
        </div>
        <div id="world_map">
            <?php onLoadMapImage($mysqli) ?>
        </div>
        <div id="items">
            <h1> Items </h1>
            <div id="items_inside">
                <div id="enter_level_button">
                    <button type="submit" name="enter_level" class="large_button" id="enter_level" value="1"> Enter Level </button>
                </div>
            </div>
        </div>
    </div>
</form>
</body>
</html>