<?php

use PHPUnit\Framework\TestCase;
use service\FileService;

require_once __DIR__ . '\..\..\Autoloader.php';

class FileServiceTest extends TestCase {


    public function testGetFileSuccess()
    {
        $body = ["fileId" => 1];
        $result = FileService::getFile($body);
        $this->assertFalse($result["err"]);
    }

    public function testGetFileFailure()
    {
        $body = [];
        $result = FileService::getFile($body);
        $this->assertTrue($result["err"]);
    }


}


