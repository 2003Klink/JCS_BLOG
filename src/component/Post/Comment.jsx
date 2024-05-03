import React, { useEffect } from "react";
import { PostSide } from "./PostSide.jsx";

export function Comment({ comments }) {


  useEffect(()=>{
    console.log(comments,"Comment");
  },[])

  return (
    <div className="flex flex-col md:w-[70%] md:mx-[15%] w-[100%] ">
      <h1 className=" text-center text-white text-4xl mdtext-6xl">Comments</h1>
      <hr />
      {comments.map((item, index) => {
        return <div className="mt-2" key={index}>

          <PostSide postData={item} isComment={true} />
        </div>;
      })}
    </div>
  );
}
