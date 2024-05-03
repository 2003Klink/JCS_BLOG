import React, { useEffect, useState } from "react";
import baseFun from "../../config/baseFun";
import dataHandler from "../../config/http.js";
import account from "../../assets/account.png";
import {
    Card,
    CardHeader,
    CardBody, Typography,
    Avatar
} from "@material-tailwind/react";
import Like from "./../../assets/like.png"
import View from "./../../assets/view.png"
export function ProfilePost() {
    const [post, setPost] = useState();

    useEffect(() => {
        dataHandler.postDataAndHandle("getAllPostByUserId", {}).then(res => {
            console.log(res);
            if (!res.err) {
                console.log(res.data);
                setPost(res.data);
            }
        }).catch(err => {
            console.error(err);
        });

    }, []);

    const handlerOnClickProfilePost = (item) => {
        baseFun.redirect("/post/get#" + item.id);
    };
    return (<div className="grid grid-cols-1 "><h1 className="flex justify-center items-center w-[90%] h-[10vh] bg-gray text-2xl xl:text-4xl text-white shadow-lg shadow-black rounded-lg mx-[5%] my-[2%] p-10 border-solid  border-b-black font-bold ">Profile side</h1>
        <div className="xl:overflow-y-auto xl:max-h-[90vh] ">
            {Array.isArray(post) && post.map((item, index) => {
                return <Card
                    shadow={false}
                    className="relative grid max-h-[40rem]  w-[80%] m-[10%] items-end justify-center overflow-hidden text-center shadow-lg shadow-black"
                    onClick={() => handlerOnClickProfilePost(item)}
                    key={index}
                >
                    <CardHeader
                        floated={false}
                        shadow={false}
                        color="transparent"
                        className="absolute inset-0 m-0 h-full w-full rounded-none bg-[url('https://images.unsplash.com/photo-1552960562-daf630e9278b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80')] bg-cover bg-center"
                    >
                        <div className="to-bg-black-10 absolute inset-0 h-full w-full bg-gradient-to-t from-black/80 via-black/50" />
                    </CardHeader>
                    <CardBody className="relative py-14 px-6 md:px-12">
                        <Typography
                            variant="h2"
                            color="white"
                            className="mb-6 font-bold shadow-lg shadow-black opacity-80 rounded bg-red leading-[1.5]"
                        >
                            {item.title}
                        </Typography>
                        <Typography  className="mb-4 text-black shadow-lg w-[100%] shadow-black rounded font-bold text-2xl p-2 bg-white">
                            {item.username}
                        </Typography>
                        <Avatar
                            size="xl"
                            variant="circular"
                            alt="tania andrew"
                            className="border-2 border-white shadow-black"
                            src={item.url ? item.url : account} />
                            <div className="bg-red w-[100%] min-h-[10vh] mt-[1vh] opacity-80 grid grid-cols-1 rounded shadow-lg shadow-black">
                                <div className="flex justify-center items-center w-[100%]">
                                    <img className="w-auto h-[5vh]" src={View} alt="" />
                                    <div className="p-5 text-white font-bold">{item.viewNumber}</div>
                                </div>
                                <div className="flex justify-center items-center w-[100%]">
                                    <img className="w-auto h-[5vh]" src={Like} alt="" />
                                    <div className="p-5 text-white font-bold">{item.like}</div>
                                </div>
                            </div>
                    </CardBody>
                </Card>;
              
            })}
            {!Array.isArray(post) && <div>Nincs Post </div>}
        </div>
    </div>);
}
