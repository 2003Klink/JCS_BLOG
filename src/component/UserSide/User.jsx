import React, { useEffect, useState } from "react";
import Navbar from "../Navbar/Navbar";
import baseFun from "../../config/baseFun.js";
import dataHandler from "../../config/http.js";
import account from "../../assets/account.png"
import {
  Card,
  CardHeader,
  CardBody, Typography,
  Avatar
} from "@material-tailwind/react";
import Like from "./../../assets/like.png"
import View from "./../../assets/view.png"
export default function User() {


  const [user, setUser] = useState([]);
  const [post, setPost] = useState([]);

  useEffect(() => {
    try {
      const UserID = { id: parseInt(window.location.href.split("#")[1]) }
      dataHandler.postDataAndHandle("getUserByID", UserID).then(res => {

        console.log(res);
        setUser(res.data[0]);
      }).catch(err => {
        console.log(err);
        //baseFun.redirect("/");
      })
    } catch (error) {
      baseFun.redirect("/")
    }
  }, [window.location.href]);
  const [hash, setHash] = useState(window.location.hash);

  useEffect(() => {
    const handleHashChange = () => {
      // A hash változott, frissítsük az állapotot
      setHash(window.location.hash);
    };

    // Regisztráljuk a hash változás eseményt
    window.addEventListener('hashchange', handleHashChange);

    // Az unmount során töröljük a hallgatót, hogy ne okozzon szivárgást
    return () => {
      window.removeEventListener('hashchange', handleHashChange);
    };
  }, []); // üres tömb, csak a komponens mount és unmount esetén fut le
  useEffect(() => {
    console.log(user.id);
    const body = {
      userId: user.id
    }
    Number.isInteger(user.id) && dataHandler.postDataAndHandle("getAllPostByUserId", body).then(res => {
      console.log(res);
      if (!res.err) {
        console.log(res.data);
        setPost(res.data);
      }
    }).catch(err => {
      console.error(err);
    })
  }, [user])

  const handlerOnClickProfilePost = (item) => {
    baseFun.redirect("/post/get#" + item.id)
  }

  return (<>
    <Navbar />
    <div className=" grid grid-cols-1">

      <div className="flex justify-center items-center">
        <div className="bg-red-700 rounded-lg flex justify-between items-center min-w-[40%] px-[10%] py-[1%] mt-[1rem] shadow-xl shadow-black">
          <img className="bg-gray-500 rounded-lg shadow-lg shadow-black" src={user.profilePicture ? user.profilePicture : account} alt="" />
          <div className="text-4xl text-white font-bold  text-center" ><div className="text-green-400">{user.username}</div> <div className="text-yellow-300">{user.level}</div> </div>
        </div>
      </div>

      <div className="w-[100%]  xl:min-h-[10vh]flex justify-center items-center">

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
        {(!Array.isArray(post) || post.length ===0) && <div className="bg-red-700 text-white w-[100%] h-[30vh] flex justify-center items-center font-bold text-3xl mt-6">Nincs Post </div>}

      </div>

      <div className="flex justify-center items-center">
      </div>


    </div>
  </>)

}