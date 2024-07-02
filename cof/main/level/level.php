<?php
include_once('../helper.php');
include_once('../moves.php');
$mysqli = onAccessDatabase();
onCreateMovesTables($mysqli);
$hero = isset($_GET['hero']);
$move_used = isset($_GET['move_used']);

if (!isset($_COOKIE['enemy_move'])) {setcookie("enemy_move", -1);}
if (!isset($_COOKIE['turn'])) {setcookie("turn", 1);}
if (!isset($_COOKIE['move_used'])) {setcookie('move_used', -1);}

if ($hero) {setcookie('hero', $_GET['hero']); setcookie('move_used', -1);}
if ($move_used) {setcookie('move_used', $_GET['move_used']);}
if ($hero or $move_used) {
    header("Location: http://$_SERVER[HTTP_HOST]/cof/main/level/level.php");
}
function onCreateMovesTables($mysqli) {
    $cq = "CREATE TABLE EnemyMoves(
        battle_id INT,
        move_id INT,
        charges INT,
        PRIMARY KEY(battle_id, move_id))";
    $mysqli -> query($cq);

    $cq = "CREATE TABLE AllyMoves(
        class_id INT,
        move_id INT,
        charges INT,
        PRIMARY KEY(class_id, move_id))";

    $mysqli -> query($cq);
    if (!($mysqli -> errno)) {
        $classes = getSelectedClassIds($mysqli);
        foreach ($classes as $id) {
            $class_info = getClassInfo($id);
            $moves = getMovesInfo($class_info['moves']);
            foreach ($moves as $move) {
                $move_id = $move['id'];
                $charges = $move['recharge'];
                $iq = "INSERT INTO AllyMoves(class_id, move_id, charges) VALUES ('$id', '$move_id', '$charges')";
                $mysqli -> query($iq);
            }
        }
        $enemies = getEnemiesBattleInfo($mysqli);
        foreach ($enemies as $enemy) {
            $id = $enemy['battle_id'];
            $moves = getMovesInfo(getEnemyInfo($enemy['enemy_id']));
            foreach ($moves as $move) {
                $move_id = $move['id'];
                $charges = $move['recharge'];
                $iq = "INSERT INTO EnemyMoves(battle_id, move_id, charges) VALUES ('$id', '$move_id', '$charges')";
                $mysqli -> query($iq);
            }
        }
    }
}
function onAccessDatabase(): mysqli
{
    mysqli_report(MYSQLI_REPORT_OFF);
    $dbhost = 'localhost';
    $dbuser = 'witold';
    $dbpass = 'witold';
    $dbname = 's32007';
    return new mysqli($dbhost, $dbuser, $dbpass, $dbname);
}
function onCreateAllyImages($mysqli) {
   $heroes = getHeroesInfo($mysqli);
   foreach ($heroes as $hero) {
        $id = $hero['class_id'];
        $text = onCreateStats($hero['att'], $hero['hp'], $hero['mana']);
        echo "
        <div class='hero_div'>
        $text
            <button type='submit' name='hero' class='hero_image_button' value='$id'>
                <img src='../../static/class_sprites/back/$id.png' alt='Back Sprite'>
            </button>
        </div>";
   }
}
function onCreateMovesBox($mysqli) {
    if ($_COOKIE['turn'] != 0) {
        $text = "";
        if (isset($_COOKIE['hero']) and $_COOKIE['hero'] != 0) {
            $heroes = getHeroesInfo($mysqli);
            foreach ($heroes as $hero) {
                if ($hero['class_id'] == $_COOKIE['hero']) {
                    $class_info = getClassInfo($_COOKIE['hero']);
                    $name = $class_info['name'];
                    $text .= "<div class='moves_header'> <h2> $name </h2> </div><div class='moves_div'>";
                    $moves = getMovesInfo($class_info['moves']);
                    foreach ($moves as $move_info) {
                        $name = $move_info['name'];
                        $id = $move_info['id'];
                        $mana = $move_info['mana'];
                        $mana_text = '';
                        if ($mana > -1) {
                            $mana_text = "<img src='../../static/stats/mana.png' alt='mana'> <text> $mana </text>";
                        }
                        $text .= "<div class='single_move_div'> <button class='moves_buttons' type='submit' name='move_used' value='$id'> 
                       $name </button> $mana_text
                       <br></div>";
                    }

                    if ($_COOKIE['move_used'] != -1) {
                        foreach ($moves as $move_info) {
                            if ($move_info['id'] == $_COOKIE['move_used']) {
                                $name = $move_info['name'];
                                $description = $move_info['description'];
                                $text .= "<div class='description_div'> $name: $description </div>";
                            }
                        }
                    }

                    $disable_attack = $_COOKIE['move_used'] == -1;
                    $disabled = '';
                    if ($disable_attack) {
                        $disabled = "disabled";
                    }
                    $text .= "</div><div class='attack_pass_div'> 
                    <button class='attack_pass_buttons' type='submit' name='attack' $disabled> Use </button> 
                    <button class = 'attack_pass_buttons' type='submit' name='pass'> Pass </button>
                    </div>";

                }
            }
        }
        echo $text;
    }
    else {
        echo "<text id='enemy_turn_text'>It's the enemy turn, wait for <br> it to finish! </text>";
    }
}
function onCreateEnemies($mysqli) {
    $text = '';
    $enemies_info = getEnemiesBattleInfo($mysqli);
    foreach ($enemies_info as $info) {
        $enemy_info = getEnemyInfo($info['enemy_id']);
        $name = $enemy_info['name'];
        $enemy_id = $enemy_info['id'];
        $stats = onCreateStats($info['att'], $info['hp'], -1);
        $text .= "
        <div class='enemy_div'>
            <h2> $name </h2>
            $stats
            <img src='../../static/enemy_sprites/$enemy_id.png' alt='Enemy'>
        </div>";
    }
    echo $text;
}

function onCreateEnemyMoves($mysqli) {
    $text = "";
    if ($_COOKIE['turn'] != 1) {
        $enemies = getEnemiesBattleInfo($mysqli);
        $text .= "<button type='submit' class='moves_buttons'> Next </button>";
        foreach ($enemies as $enemy) {
            if ($enemy['has_moved'] == 0) {
                $enemy_class = getEnemyInfo($enemy['enemy_id']);
                $text .= onEnemyUseRandomMove($enemy, $mysqli);
                break;
            }
        }
    }
    echo $text;
}

?>
<link href="level.css" rel="stylesheet">
<link href="../helper.css" rel="stylesheet">
<html lang="en">
<body>
<form action="level.php">
    <div id="main">
        <div id="top_side">
            <div id="enemies">
                <div id="enemy_moves" class="moves_box">
                    <?php onCreateEnemyMoves($mysqli) ?>
                </div>
                <div id="enemy_sprites">
                    <?php onCreateEnemies($mysqli) ?>
                </div>
            </div>
            <div id="ally_moves" class="moves_box">
                <?php onCreateMovesBox($mysqli) ?>
            </div>
        </div>
        <div id="allies">
            <div id="ally_buttons"> <?php onCreateAllyImages($mysqli) ?></div>
        </div>
    </div>
</form>
</body>
</html>
