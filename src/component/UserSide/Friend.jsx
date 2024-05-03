import React, { useEffect, useState } from "react";
import dataHandler from "../../config/http.js";
import account from "../../assets/account.png";

export function Friend() {

    const [Follow, setFollow] = useState([]);
    const [Follower, setFollower] = useState([]);
    const [Switch, setSwitch] = useState(true);

    useEffect(() => {

        dataHandler.postDataAndHandle("getFollowByUserId", {}).then(res => {
            //console.log(res);
            setFollow(res.data);
        }).catch(err => {
            console.error(err);
        });
        dataHandler.postDataAndHandle("getFollowerByUserId", {}).then(res => {
            console.log(res);
            setFollower(res.data);
        }).catch(err => {
            console.error(err);
        });

    }, []);

    return (
        <div>
            <div className="h-[10vh] w-[100%]  flex justify-between items-start">
                <button className="w-[40%] h-[8vh] p-[1vh] rounded-lg bg-red text-white font-bold hover:bg-red-100 ml-2 mt-2" onClick={() => setSwitch(true)}>Followed</button>
                <button className="w-[40%] h-[8vh] p-[1vh] rounded-lg bg-red text-white font-bold hover:bg-red-100 mr-2 mt-2" onClick={() => setSwitch(false)}>Follower</button>
            </div>
            <div className="max-h-[100vh] overflow-auto">
                {Array.isArray(Follow) && Switch && (
                    <div className="w-[100%] h-[]">
                        {Follow.map((item, index) => (
                            <a
                                href={`/user#${item.id}`}
                                key={"follow" + index}
                                className={`grid grid-cols-1 ${index % 2 === 0 || index === 0 ? "bg-red" : "bg-white"} mb-[1rem]`}
                            >
                                <div className="flex justify-between items-start min-h-[10vh] p-5 shadow-lg shadow-black">
                                    <div className="flex justify-center items-center w-[50%]">
                                        <img className={`${index % 2 === 0 || index === 0 ? "bg-black" : "bg-red"} rounded-full w-[15vh] h-[15vh] p-2 shadow-lg shadow-black object-contain`} src={item.url !== null ? item.url : account} alt="" />
                                    </div>
                                    <div className="flex justify-center items-center w-[50%]">
                                        <div className={`${index % 2 === 0 || index === 0 ? `bg-white text-black rounded p-3` : `bg-black text-white p-3 rounded`} text-2xl text-center font-bold max-w-[40vw] line-clamp-2`}>{item.username}</div>
                                    </div>

                                </div>
                            </a>
                        ))}
                    </div>
                )}

                {((Array.isArray(Follower) && !Switch) && <div> {Follower.map((item, index) => (<a
                    href={`/user#${item.id}`}
                    key={"follow" + index}
                    className={`grid grid-cols-1 ${index % 2 === 0 || index === 0 ? "bg-red" : "bg-white"}`}
                >
                    <div className="flex justify-between items-start min-h-[10vh] p-5 shadow-lg shadow-black">
                        <div className="flex justify-center items-center w-[50%]">
                            <img className={`${index % 2 === 0 || index === 0 ? "bg-black" : "bg-red"} rounded-full w-[15vh] h-[15vh] p-2 shadow-lg shadow-black object-contain`} src={item.url !== null ? item.url : account} alt="" />
                        </div>
                        <div className="flex justify-center items-center w-[50%]">
                            <div className={`${index % 2 === 0 || index === 0 ? `bg-white text-black rounded p-3` : `bg-black text-white p-3 rounded`} text-2xl text-center font-bold `}>{item.username}</div>
                        </div>

                    </div>
                </a>)
                )}</div>)}
            </div>
        </div>);
}
