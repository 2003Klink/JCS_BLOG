import React,{useEffect,useState} from "react";
import Navbar from "../Navbar/Navbar.jsx";
import baseFun from "../../config/baseFun.js";
import dataHandler from "../../config/http.js";
import { MakeComment } from "./MakeComment.jsx";
import { PostSide } from "./PostSide.jsx";
import { Comment } from "./Comment.jsx";
export default function PostGet() {
  const [postData, setPostData] = useState([]);
  const [comment, setComment] = useState([]);

  useEffect( () => {
    
      if (!window.location.href.split("#")[1]) {
        baseFun.redirect("/");
        return;
      }
  
      const postId = parseInt(window.location.href.split("#")[1]);
  
      try {
        console.log({ postId: postId });
        dataHandler.postDataAndHandle("getPostById", { postId: postId }).then(res=>{
          console.log(res);
        if (res.data.length === 0) {
          baseFun.redirect("/");
          return;
        }
        setPostData(res.data[0]);
        console.log(res.data[0]);
        
          dataHandler.postDataAndHandle("getCommentByPostId", { postId: postId }).then(result=>{
            console.log(result);
            setComment(Array.isArray(result.data) ? result.data : []);
          })
          
        
        })
        
      } catch (error) {
        console.error(error);
      }
    
  
 
  }, [window.location.pathname]);
  

  return (
    <>
      <Navbar />
      <div className="w-[100%] shadow-xl shadow-black min-h-[10vh]  bg-gray p-10">
        {postData != [] && <PostSide postData={postData} />}
        {postData != [] && <MakeComment postData={postData} />}
        {postData != [] && <Comment comments={comment} />}
      </div>
    </>
  );
}

