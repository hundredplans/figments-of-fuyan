<?php
include_once('helper.php');
$move_paths = array("3" => "RockSlash");
function getUseableMoves($battle_id, $mysqli) {
    $useable_moves = array();
    $sq = "SELECT move_id, charges FROM EnemyMoves WHERE battle_id='$battle_id'";
    $result = $mysqli -> query($sq);
    if ($result -> num_rows > 0) {
       while ($row = $result -> fetch_assoc()) {
           if ($row['charges'] > 0) {
               array_push($useable_moves, $row['move_id']);
           }
       }
    }
    return $useable_moves;
}
function onEnemyUseRandomMove($enemy, $mysqli) {
    $usable_moves = getUseableMoves($enemy['battle_id'], $mysqli);
    $text = "";
    if (!empty($usable_moves)) {
        $move_id = $usable_moves[array_rand($usable_moves)];
        $move_info = getMoveInfo($move_id);
        $hero_info = onEnemyFindRandomTarget($mysqli);
        onEnemyUseMove($enemy, $hero_info, $move_info, $mysqli);
    }
    else {
        $text .= "The enemy has no available moves!";
    }
    return $text;

}

function onEnemyFindRandomTarget($mysqli) {
    $heroes = getHeroesInfo($mysqli);
    return $heroes[array_rand($heroes)];
}

function onEnemyUseMove($enemy, $hero, $move_info, $mysqli) {
    $move_id = $move_info['id'];
    $battle_id = $enemy['battle_id'];
    $uq = "UPDATE EnemyMoves SET charges=0 WHERE move_id='$move_id' and battle_id='$battle_id'";
    $mysqli -> query($uq);

    switch($move_info['id']) {
        case 3: onUseRockslash();
    }
}

function onUseRockslash(){

}