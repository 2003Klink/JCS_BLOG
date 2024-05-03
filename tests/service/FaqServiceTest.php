<?php
use PHPUnit\Framework\TestCase;
use service\FaqService;

require_once __DIR__ . '\..\..\Autoloader.php';

class FaqServiceTest extends TestCase{

    // public function testcreateFaqSuccess(){
    //     $dataSend = array(
    //         "name"=>"test_".rand(0,10000000));
    //     $classes = FaqService::createFaq($dataSend);
    //     $this->assertFalse($classes["err"]);
    // }

//     public function testCreateFaqStepSuccess()
// {
//     $data = array(
//         "id" => 4,
//         "stepNum" => 1,
//         "fileId" => 23,
//         "content" => "Content"
//     );
//     $result = FaqService::createFaqStep($data);
//     $this->assertIsArray($result);
//     $this->assertArrayHasKey("err", $result);
//     $this->assertFalse($result["err"]);
// }
    

    public function testCreateFaqStepFailure()
    {
        $data = array(
            "stepNum" => 1,
            "fileId" => 456,
            "content" => "Content"
        );
        $result = FaqService::createFaqStep($data);
        $this->assertTrue($result["err"]);
    }

    public function testGetAllFaqSuccess()
    {
        $result = FaqService::getAllFaq();
        $this->assertNotEmpty($result);
        $this->assertFalse($result["err"]);
    }

    // public function testGetAllFaqFailure()
    // {
    //     if (!property_exists(FaqService::class, 'simulateError')) {
    //         FaqService::$simulateError = false;
    //     }
    //     FaqService::$simulateError = true;
    //     $result = FaqService::getAllFaq();
    //     FaqService::$simulateError = false;
    //     $this->assertNotEmpty($result);
    //     $this->assertArrayHasKey("err", $result);
    //     $this->assertTrue($result["err"]);
    // }   
     public function testCreateFaqSuccess()
    {
        $data = ["name" => "Example FAQ"];
        $result = FaqService::createFaq($data);
        $this->assertFalse($result["err"]);
    }

    public function testCreateFaqFailure()
    {
        $data = array("name" => null);
        $result = FaqService::createFaq($data);
        $this->assertTrue($result["err"]);
    }

    public function testGetFaqByIdSuccess()
    {
        $data = ["faqId" => 123];
        $result = FaqService::getFaqById($data);
        $this->assertFalse($result["err"]);
    }

    public function testGetFaqByIdFailure()
    {
        $data = [];
        $result = FaqService::getFaqById($data);
        $this->assertTrue($result["err"]);
    }

}