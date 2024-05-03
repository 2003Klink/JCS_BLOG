<?php

namespace service;

require_once __DIR__ . '\..\..\Autoloader.php';

use config\Exception;
use config\HttpStatus;
use config\JWThandler;
use model\UserModel;
use config\Req;

class PostService
{
    static function createPost(array $data)
    {
        $verifyJWT = JWThandler::verifyJWT(Req::getReqToken());

        if (!isset($verifyJWT["data"]["data"][0]["id"])) {
            Exception::msg(["err" => true, "data" => "Not found user Datas"], HttpStatus::BAD_REQUEST);
        }
        isset($data["postId"]) ? true : $data["postId"] = null;
        if (!isset($data["title"])) {
            return array("err" => true);
        }
        if (!isset($data["text"])) {
            return array("err" => true);
        }
        if (!isset($data["carName"])) {
            return array("err" => true);
        }
        if (!isset($data["carBrand"])) {
            return array("err" => true);
        }
        isset($data["IsFile"]) ? false : $data["IsFile"] = null;
        $senderArray = array(
            "InPost" => $data["postId"],
            "InTitle" => $data["title"],
            "InText" => $data["text"],
            "InUserID" => $verifyJWT["data"]["data"][0]["id"],
            "hasFile" => $data["IsFile"],
            "FileID" => isset(Req::$fileData["id"]) ? Req::$fileData["id"] : 1,
            "carName" => $data["carName"],
            "carBrand" => $data["carBrand"]
        );
        $service = UserModel::CallProcedure($senderArray, "createPost");
        return array("err" => $service["err"], "data" => $service["data"]);
        // print_r(UserModel::CallProcedure($data,"createPost"));


    }
    public static function getPostById(array $data)
    {

        $verifyJWT = JWThandler::verifyJWT(Req::getReqToken());

        if (isset($verifyJWT["data"]["data"][0]["id"]) && isset($data["postId"])) {

            $returnData =  UserModel::CallProcedure(array("postId" => $data["postId"], "userId" => $verifyJWT["data"]["data"][0]["id"]), 'getPostById');
            return $returnData;
        } else {
            Exception::msg(array("err" => true, "data" => "Null"));
        }
    }
    public static function getAllPostByUserId(array $data)
    {

       
        if (isset($data["userId"])) {

            $returnData =  UserModel::CallProcedure(array("userId" => $data["userId"]), 'getAllPostByUserId');
                return $returnData;

        } else {
            $verifyJWT = JWThandler::verifyJWT(Req::getReqToken());

            if (isset($verifyJWT["data"]["data"][0]["id"])) {

                $returnData =  UserModel::CallProcedure(array("userId" => $verifyJWT["data"]["data"][0]["id"]), 'getAllPostByUserId');
                return $returnData;
            } else {
                Exception::msg(array("err" => true, "data" => "Null"));
            }
        }
    }
    public static function createEvaluation($data)
    {

        $verifyJWT = JWThandler::verifyJWT(Req::getReqToken());

        if (isset($verifyJWT["data"]["data"][0]["id"]) && $data["postId"]) {

            $returnData =  UserModel::CallProcedure(array("postId" => $data["postId"], "userId" => $verifyJWT["data"]["data"][0]["id"]), 'createEvaluation');
            return $returnData;
        } else {
            Exception::msg(array("err" => true, "data" => "Null"));
        }
    }
    public static function deleteEvaluation($data)
    {

        $verifyJWT = JWThandler::verifyJWT(Req::getReqToken());

        if (isset($verifyJWT["data"]["data"][0]["id"]) && $data["postId"]) {

            $returnData =  UserModel::CallProcedure(array("postId" => $data["postId"], "userId" => $verifyJWT["data"]["data"][0]["id"]), 'deleteEvaluation');
            return $returnData;
        } else {
            Exception::msg(array("err" => true, "data" => "Null"));
        }
    }
}
