<?php
$MAX_CLASS_COUNT = 4;

$classes_info = file_get_contents('../../static/classes/classes_info.json');
$classes_info = json_decode($classes_info, true);
$classes_info = $classes_info["classes_info"];

$moves_info = file_get_contents("../../static/moves_info.json");
$moves_info = json_decode($moves_info, true);
$moves_info = $moves_info["moves_info"];

$levels_info = file_get_contents('../../static/levels_info.json');
$levels_info = json_decode($levels_info, true);
$levels_info = $levels_info["levels_info"];

$enemies_info = file_get_contents('../../static/enemies_info.json');
$enemies_info = json_decode($enemies_info, true);
$enemies_info = $enemies_info["enemies_info"];

function getSelectedClassIds($mysqli): array {
    $select_query = "SELECT class_id FROM SavesClasses WHERE save_id = '1'";
    $result = $mysqli -> query($select_query);
    $class_ids = array();
    if ($result -> num_rows > 0) {
        while ($row = $result -> fetch_assoc()) {
            array_push($class_ids, $row["class_id"]);
        }
    }
    return $class_ids;
}

function getHeroesInfo($mysqli): array {
   $select_query = "SELECT class_id, att, hp, mana, max_hp, max_att, max_mana FROM SavesClasses WHERE save_id = '1'";
   $result = $mysqli -> query($select_query);
   $info = array();
   if ($result -> num_rows > 0) {
       while ($row = $result -> fetch_assoc()) {
           array_push($info, $row);
       }
   }
   return $info;
}

function getClassInfo($id): array {
    foreach ($GLOBALS['classes_info'] as $info) {
       if ($info['id'] == $id) {
           return $info;
       }
    }
    return array();
}

function onLoadLevelID($mysqli) {
    $sq = "SELECT level_id FROM Saves WHERE save_id=1";
    $result = $mysqli -> query($sq);
    if ($result -> num_rows > 0) {
        $row = $result->fetch_assoc();
        return $row['level_id'];
    }
    return 0;
}

function onCreateStats($att, $hp, $mana) {
    $text = "<div class=hero_info_stats>";
    $stats = array('att' => $att, 'hp' => $hp);
    if ($mana > -1) {$stats['mana'] = $mana;}
    foreach($stats as $key => $value) {
        $text .= "<div class='hero_info_single'> 
                    <text class='stat_text'> $value </text> 
                    <img src='../../static/stats/$key.png' alt='$key'> 
                  </div>";
    }
    $text .= "</div>";
    return $text;
}

function getMovesInfo($moves) {
    $infos = array();
    foreach ($moves as $move_id) {
        foreach ($GLOBALS['moves_info'] as $move_info) {
           if ($move_info['id'] == $move_id) {
               array_push($infos, $move_info);
           }
        }
    }
    return $infos;
}

function getMoveInfo($move_id) {
    foreach ($GLOBALS['moves_info'] as $move_info) {
        if ($move_info['id'] == $move_id) {
            return $move_info;
        }
    }
    return array();
}

function getLevelInfo($id) {
    foreach ($GLOBALS['levels_info'] as $info) {
       if ($info['id'] == $id) {
           return $info;
       }
    }
    return array();
}

function getEnemyInfo($id) {
   foreach ($GLOBALS['enemies_info'] as $info) {
       if ($info['id'] == $id) {
           return $info;
       }
   }
   return array();
}

function getEnemiesBattleInfo($mysqli) {
    $sq = "SELECT battle_id, enemy_id, max_hp, max_att, hp, att, has_moved FROM Enemies";
    $result = $mysqli -> query($sq);
    $infos = array();
    if ($result -> num_rows > 0) {
        while ($row = $result -> fetch_assoc()) {
           array_push($infos, $row);
        }
    }
    return $infos;
}
function getEnemyBattleInfo($battle_id, $mysqli) {
    $sq = "SELECT battle_id, enemy_id, max_hp, max_att, hp, att FROM Enemies WHERE $battle_id = '$battle_id'";
    $result = $mysqli -> query($sq);
    if ($result -> num_rows > 0) {return $result -> fetch_assoc();}
    return array();
}
