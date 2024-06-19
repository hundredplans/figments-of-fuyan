<?php
$MAX_CLASS_COUNT = 4;

$classes_info = file_get_contents('../../static/classes/classes_info.json');
$classes_info = json_decode($classes_info, true);
$classes_info = $classes_info["classes_info"];

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
   $select_query = "SELECT class_id, att, hp, mana FROM SavesClasses WHERE save_id = '1'";
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