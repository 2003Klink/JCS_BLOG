import React,{useEffect,useState} from "react";
import dataHandler from "../../config/http";

export default function Faq(params) {
    
    const [faq,setFaq]=useState([]);

    useEffect(()=>{
        dataHandler.postDataAndHandle("getAllFaq",{}).then(res=>{
            !res.err?setFaq(res.data):setFaq([])
        })
    },[])

    return (<div className="w-[100%] min-h-[20vh]">
        
        <div className="w-[100%] min-h-20vh my-20 p-10 bg-red ">
            <div className="grid grid-cols-1">
            <h1 className=" w-[100%] text-center text-white text-6xl font-extrabold">FAQ</h1>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2">
            {Array.isArray(faq) && faq.map((item,index)=>{
                return <a key={index} href={`/faq#${item.id}#${item.question}`} className="bg-white text-black text-3xl text-center mx-5 my-6 rounded-xl px-6 py-5 hover:bg-gray-400 shadow-lg shadow-black font-bold"> {item.question} </a>
            }) }
            </div>
            
        </div>
    </div>)

}