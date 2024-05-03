import React, { useEffect, useState } from "react";
import Navbar from "../Navbar/Navbar";
import baseFun from "../../config/baseFun";

import { ProfilePost } from "./ProfilePost.jsx";
import { Friend } from "./Friend.jsx";
import dataHandler from "../../config/http.js";
import setting from "../../assets/setting.png"
export default function Profile() {

    const [profile, setProfile] = useState({});

    useEffect(() => {
        dataHandler.postDataAndHandle("getProfilUser").then(res => {
            console.log(res);
            setProfile(res.data[0])
        }).catch(err => {
            baseFun.logout();
            baseFun.redirect("/")
        })
    }, [])
    useEffect(()=>{
        console.log("Frissült a Profile");
        console.log(profile.url);
    },[profile])


    return (
        <>
            <Navbar />
            <section className="w-[100%] min-h-[80vh] bg-red flex justify-center">
                <div className="w-[80%] min-h-[10vh] bg-white mt-6 mb-6 rounded-xl xl:p-10">
                    <header className=" min-h-[5vh]  border-b-4 bg-white shadow-black shadow-lg  ">
                        <div className="md:flex md:justify-start mx-[0] md:w-[90%] md:mx-[5%] md:items-center grid grid-cols-1 text-center">
                            <div className="w-[100%] md:w-auto flex justify-center items-center">
                                 <img src={profile.url==null?"":profile.url} alt="" className="rounded-full h-auto w-[auto] xl:h-[18vh]  m-[1vh] shadow-lg shadow-black" />
                            </div>
                            <h2 className="text-3xl text-black font-bold">{baseFun.getUserIDFromLS().username}</h2>
                            
                        </div>
                    </header>
                    <section className="xl:flex grid grid-cols-1 justify-between items-start">
                        <div className="w-[100%] min-h-[10vh] ">
                            <Friend />
                        </div>
                        <div className=" w-[100%]  xl:min-h-[10vh]">
                            <ProfilePost />
                        </div>
                    </section>
                </div>
            </section>
        </>

    )
}