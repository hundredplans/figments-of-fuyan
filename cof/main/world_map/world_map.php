<?php
include_once('../helper.php');
$mysqli = onAccessDatabase();
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
            <div class='hero_info_stats'>
        ";

        $stats = array('att' => $att, 'hp' => $hp);
        if ($mana > -1) {$stats['mana'] = $mana;}
        foreach($stats as $key => $value) {
            echo "<div class='hero_info_single'> <text> $value </text> <img src='../../static/stats/$key.png' alt='$key'> </div>";
        }
        echo "</div></div>";
    }
}

?>

<link href="world_map.css" rel="stylesheet">
<html lang="en">
<body>
<div id="main">
    <div id="selected_heroes">
        <h1> Heroes </h1>
        <div id="heroes_info">
            <?php onCreateClasses($mysqli); ?>
        </div>
    </div>
    <div id="world_map">
        <img id="world_map_img" src="world_map.png" alt="World Map">
    </div>
    <div id="items">
        <h1> Items </h1>
    </div>
</div>
</body>
</html>