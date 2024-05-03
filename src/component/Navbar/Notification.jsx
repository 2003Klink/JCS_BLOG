import React, { useEffect, useState } from "react";
import dataHandler from "../../config/http";
import baseFun from "../../config/baseFun";
export default function Notification({ onMouseLeave }) {
    //getNotificationsById
    //selectedNotification


    const [isOnMouse, setIsOnMouse] = useState();

    const [notificatons, setNotification] = useState();


    const handlerOnLeftMouse = () => {
        if (isOnMouse != null && isOnMouse) {
            onMouseLeave()
        }
    }
    const handlerOnEnterMouse = () => {
        setIsOnMouse(true)

    }

    useEffect(() => {
        dataHandler.postDataAndHandle("getNotificationById", {}).then(res => {
            console.log(res);
            setNotification(Array.isArray(res.data) ? res.data.reverse() : [])
        }).catch(err => {
            console.log(err);
        })
    }, [])



    const handlerNotificationClickEvent = (index, type, tableId, notificatonId) => {
        console.log(index, type, tableId);
        switch (type) {
            case "Post":
                dataHandler.postDataAndHandle("selectedNotification", { notificationId: notificatonId }).then(res => {
                    console.log(tableId);
                    console.log(res);
                    baseFun.redirect(`/post/get#${tableId}`);
                }).catch(err => {
                    console.log(err);
                })

        }
    }

    return (
        <div className="absolute top-[60px] md:right-[10rem] right-0 bg-red-700 rounded-lg md:w-[25%] w-[80%] border-2 shadow-xl shadow-black border-gray-200 grid grid-cols-1 max-h-[40vh] overflow-auto pt-16"
            onMouseEnter={handlerOnEnterMouse}
            onMouseLeave={handlerOnLeftMouse}
            key={"Post"+Math.floor(Math.random()+5000)}
        >
            <div className="bg-gray p-3 text-center text-white text-2xl font-extrabold shadow-xl absolute ">Notification</div>

            {Array.isArray(notificatons) && notificatons.map((item, index) => {
             

                switch (item.type) {
                    case "Message":
                        return (<div key={"Message"+item.id +item.type} onClick={() => { handlerNotificationClickEvent(index, item.type, item.tableID, item.id) }} className="w-[80%] mx-[10%] min-h-[5vh] bg-red-500 my-[0.25rem] py-2 px-3 text-white flex justify-left items-center rounded-lg">
                            <img src={item.sender_url} className="h-[5vh] mr-5 rounded-full" alt="" />
                            <div className="grid grid-cols-1">
                                <div className="flex justify-center items-center">
                                    <div className="px-[1rem]">{item.type}</div>
                                    <div className="px-[1rem]">{item.sender_username}</div>
                                </div>
                                <hr />
                                <div className="text-xs">{baseFun.timeSender(item.timestamp)}</div>

                            </div>
                        </div>)
                    case "Post":
                        return (<div key={"Post"+item.id +item.type} onClick={() => { handlerNotificationClickEvent(index, item.type, item.tableID, item.id) }} className="w-[80%] mx-[10%] min-h-[5vh] bg-green-500 my-[0.25rem] py-2 px-3 text-white flex justify-left items-center rounded-lg">
                            <img src={item.sender_url} className="h-[5vh] mr-5 rounded-full" alt="" />
                            <div className="grid grid-cols-1">
                                <div className="flex justify-center items-center">
                                    <div className="px-[1rem]">{item.type}</div>
                                    <div className="px-[1rem]">{item.sender_username}</div>
                                </div>
                                <hr />
                                <div className="text-xs">{baseFun.timeSender(item.timestamp)}</div>

                            </div>
                        </div>)
                    case "Liked":
                        return (<div key={"Liked"+item.id +item.type} onClick={() => { handlerNotificationClickEvent(index, item.type, item.tableID, item.id) }} className="w-[80%] mx-[10%] min-h-[5vh] bg-blue-500 my-[0.25rem] py-2 px-3 text-white flex justify-left items-center rounded-lg">
                            <img src={item.sender_url} className="h-[5vh] mr-5 rounded-full" alt="" />
                            <div className="grid grid-cols-1">
                                <div className="flex justify-center items-center">
                                    <div className="px-[1rem]">{item.type}</div>
                                    <div className="px-[1rem]">{item.sender_username}</div>
                                </div>
                                <hr />
                                <div className="text-xs">{baseFun.timeSender(item.timestamp)}</div>

                            </div>
                        </div>)



                }


            })}
        </div>
    )
}
