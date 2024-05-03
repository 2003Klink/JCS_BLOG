import React, { useEffect, useState } from "react";
import baseFun from "../../config/baseFun.js";
import dataHandler from "../../config/http.js";
import account from "../../assets/account.png";

export function PostSide({ postData, isComment = false, }) {


  const [liked, setLiked] = useState(postData.liked); //ez még meg kell írni h Comment Commentjét meg lehessen hívni

  const handlerLike = () => {
    if (!liked) {
      dataHandler.postDataAndHandle("createEvaluation", { postId: postData.id }).then(res => {
        console.log(res);
        alert("liked This Post");
        setLiked(1);
      }).catch(err => {
        console.log(err);
      });
    } else {
      dataHandler.postDataAndHandle("deleteEvaluation", { postId: postData.id }).then(res => {
        console.log(res);
        alert("delete liked This Post");
        setLiked(0);
      }).catch(err => {
        console.log(err);
      });
    }
    changeLike();

  };
  useEffect(() => {

    console.log(postData);
    setLiked(postData.liked === 1);
    console.log(postData.liked, "liked?");
  }, [postData]);

  return (
    <div className={` w-full md:max-w-full md:flex`}>
      {postData.Post_file != null && <div className="max-h-48 w-[100%]  md:h-auto md:w-48 flex-none bg-cover rounded-t md:rounded-t-none md:rounded-l text-center overflow-hidden" title="Woman holding a mug">
        { !isComment && <img className="h-[100%] w-[100%] object-cover" src={postData.Post_file} />}
        { isComment && <img className="h-[100%] w-[100%] object-cover" src={postData.PPFile} />}
      </div>}

      <div className={`${isComment ? `bg-slate-700` : `bg-white`} h-[100%] w-[100%] border-r border-b border-l border-gray-400 md:border-l-0 md:border-t md:border-gray-400  rounded-b md:rounded-b-none md:rounded-r p-4 flex flex-col justify-between leading-normal`}>

        <div className="mb-8">
          <div className="flex items-center border-b-2 border-black border-separate shadow-md shadow-white mb-5">
            { !isComment && <div className="p-2 rounded flex justify-center items-center mb-3"><img className="w-auto min-h-[10vh] rounded-full  shadow-md shadow-white" src={postData.PPUrl ? postData.PPUrl : account} alt="Avatar of Jonathan Reinink" /></div>}
            { isComment  && <div className="p-2 rounded flex justify-center items-center mb-3"><img className="w-auto min-h-[10vh] rounded-full  shadow-md shadow-white" src={postData.PPFile ? postData.PPFile : account} alt="Avatar of Jonathan Reinink" /></div>}

            <div className="text-sm flex justify-center items-center text-center">
              <p className={`${isComment ? `text-white`:`text-black`} leading-none font-bold md:text-3xl text-center`}>{postData.username}</p>

            </div>
          </div>
          <div className={`${isComment ? `text-white`:`text-black`} font-bold text-xl mb-2`}>{postData.title}</div>
          <p className={`${isComment ? `text-white`:`text-black`} text-base overflow-auto max-h-[50vh] pe-4 text-justify`}>{postData.text}</p>
        </div>
        {postData.url !== null && <div className="w-[100%] min-h-[10vh]">
          <h1 className={`${isComment ? `text-white`:`text-black`} w-[100%] border-b-2 border-black mb-2 text-2xl font-bold px-10  `}>Images</h1>
          <img className="rounded shadow-md shadow-white opacity-30 hover:opacity-70 h-[15vh] w-auto" src={postData.url} />
        </div>}
        <div className="grid grid-cols-1">


          <div className="flex justify-between items-center ">
            <p className={`${isComment ? `text-white`:`text-black`}  `}>{baseFun.timeSender(postData.timestamp)}</p>
            {(!isComment && baseFun.isLogin()) &&<button onClick={handlerLike} className={`px-2 py-1 m-1 rounded-full   ${liked ? "bg-green-400" : "bg-red-700"} text-white hover:text-black hover:bg-white`}>Like</button>
}


          </div>
        </div>

      </div>

    </div>
  );
}
