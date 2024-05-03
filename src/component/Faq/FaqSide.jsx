import React, { useEffect, useState } from "react";
import Navbar from "../Navbar/Navbar.jsx";
import dataHandler from "../../config/http.js";

function Step({ step: { FAQID, content, question, stepNumber, url }, index }) {
    return (<div key={index} className="w-[100%] justify-center items-center grid grid-cols-1  bg-red rounded-xl my-5">
        <h1 className="text-5xl text-center text-white font-extrabold drop-shadow-2xl"> {stepNumber}  Step </h1>
        <div className="justify-between items-center grid grid-cols-1 md:grid-cols-2">
            <div className="justify-between items-center ">

                {!(stepNumber % 2 == 0 || stepNumber === 0) &&
                    <div className="md:w-[100%] md:h-auto  my-5 rounded-[5rem] justify-center items-center flex">
                        <div className="w-[80%] bg-white rounded mx-[10%] shadow-lg shadow-black">
                            <div className="font-bold text-center text-4xl border-b-2 p-2  border-black">{question}</div>
                            <div className="font-bold text-center text-2xl p-2 ">
                                <div className="w-[30%] mx-[35%] h-[10vh] my-[5vh] bg-red text-white rounded-lg shadow-lg shadow-black">
                                    {content}
                                </div>
                            </div>
                        </div>
                    </div>}

                {(stepNumber % 2 == 0 || stepNumber === 0) &&
                    <div className="md:w-[100%] md:h-auto  my-5 rounded-[5rem] justify-center items-center flex shadow-lg shadow-black">
                        <img className="hue-rotate-180 md:w-[100%] md:h-auto h-[30vh] bg-cover md:p-8 rounded-[5rem] shadow-lg shadow-black" src={url} alt="" />
                    </div>}

            </div>
            <div className="justify-between items-center ">

            {(stepNumber % 2 == 0 || stepNumber === 0) &&
                    <div className="md:w-[100%] md:h-auto  my-5 rounded-[5rem] justify-center items-center flex">
                        <div className="w-[80%] bg-white rounded mx-[10%] shadow-lg shadow-black">
                            <div className="font-bold text-center text-4xl border-b-2 p-2  border-black">{question}</div>
                            <div className="font-bold text-center text-2xl p-2 ">
                                <div className="w-[30%] mx-[35%] h-[10vh] my-[5vh] bg-red text-white rounded-lg shadow-lg shadow-black">
                                    {content}
                                </div>
                            </div>
                        </div>
                    </div>}

                    {!(stepNumber % 2 == 0 || stepNumber === 0) &&
                    <div className="md:w-[100%] md:h-auto  my-5 rounded-[5rem] justify-center items-center flex shadow-lg shadow-black">
                        <img className="hue-rotate-180 md:w-[100%] md:h-auto h-[30vh] bg-cover md:p-8 rounded-[5rem] shadow-lg shadow-black" src={url} alt="" />
                    </div>}


            </div>
        </div>
    </div>)
}

export default function FaqSide() {
    const [num, setNum] = useState();
    const [title, setTitle] = useState();
    useEffect(() => {

        if (Number.isInteger(parseInt(window.location.href.split("#")[1]))) {
            dataHandler.postDataAndHandle("getFaqById", {
                faqId: parseInt(window.location.href.split("#")[1])
            }).then(res => {
                Array.isArray(res.data) ? setNum(res.data) : console.log(res);
                Array.isArray(res.data) && res.data[0] ? setTitle(res.data[0].question) : setTitle("Nincsen elérhető Cím");
            }).catch(err => {
                console.log(err);
            })
        }

    }, [window.location.href])

    return (<>
        <Navbar />
        <div className="w-[100%]  sm:text-4xl text-2xl md:text-8xl text-center">
            {title}
        </div>
        {Array.isArray(num) && num.map((item, index) => {
            console.log(item);
            return <Step step={item} index={index} />
        })}
    </>)

}