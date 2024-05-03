import React, { useEffect, useState } from "react";
import inputImg from "../../assets/fileInput.png";
import baseFun from "../../config/baseFun";
import dataHandler from "../../config/http";

export function MakeComment({ postData }) {
  const [fileData, setFileData] = useState(null);
  const [titleData, setTitleData] = useState("");
  const [textData, setTextData] = useState("");
  const [makeCommentPostData, setMakeCommentPostData] = useState(null);
  const [state, setState] = useState({
    title: null,
    text: null,
    postId: null,
    IsFile: false,
    file: {
      content: null,
      name: null,
      extension: null,
      type: null,
      size: null
    }
  });

  const handlerFile = () => {
    window.document.getElementById("formInputFile").click();
  };

  const handlerFileOnChange = (e) => {
    const file = e.target.files[0];
    setFileData(file);
  };

  const handlerTitle = (e) => {
    setTitleData(e.target.value);
  };

  const handlerText = (e) => {
    setTextData(e.target.value);
  };



  const readFileAsync = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onloadend = () => resolve(reader.result.split(",")[1]);
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  };

  const handlerSubmit = async (e) => {
    e.preventDefault();
    if (!baseFun.isLogin()) {
      baseFun.redirect("/sign");
      return;
    }

    const selectedFile = fileData;

    try {
      let base64Content = null;
      if (selectedFile) {
        base64Content = await readFileAsync(selectedFile);
      }

      const statement = {
        title: titleData,
        text: textData,
        postId: postData.id,
        IsFile: !!selectedFile, // Set to true if there's a file, false otherwise
        file: selectedFile
          ? {
            content: base64Content,
            name: selectedFile.name.split(".")[0],
            extension: selectedFile.name.split(".").pop(),
            type: selectedFile.type.split("/")[0],
            size: selectedFile.size
          }
          : null
      };

      if (textData != "" && titleData != "") {
        dataHandler.postDataAndHandle("createPost", statement)
          .then((res) => {
            console.log(res);
            if (!res.err) {
              setFileData(null)
              setTextData("")
              setTitleData("")
              document.getElementById("textarea").value = "";
              document.getElementById("title").value = "";
            }
          })
          .catch((err) => {
            console.log(err);
          });
      }else{
        alert("Nem tutsz küldeni üres formot")
      }

    } catch (error) {
      console.error("Error occurred while reading the file:", error);
    }
  };

  useEffect(() => {
    setMakeCommentPostData(postData);
    setState({ ...state, postId: postData.id });
  }, [postData]);

  return (
    <>
      {baseFun.isLogin() ? (
        <div className="md:w-[80%] min-h-[10vh] bg-gray-400 md:mx-[10%] w-[100%] grid grid-cols-1 rounded md:my-[2vw] my-[1vw]">
          <h1 className="text-center text-black font-bold text-2xl border-b-2 border-spacing-1 border-black mb-[2vh] pb-[1vh]">What's in your mind</h1>
          <div className="flex justify-center items-center">
            <form className="grid grid-cols-1 w-[100%]" onSubmit={(e) => handlerSubmit(e)}>
              <div className="grid grid-cols-1 md:flex w-[100%] justify-center items-center">
                <input id="title" className="shadow-lg shadow-black md:mx-[10%] w-[100%] border-none" placeholder="Title" onChange={(e) => handlerTitle(e)} type="text" required />
              </div>
              <div className="grid grid-cols-1 md:flex w-[100%] justify-center items-center ">
                <textarea id="textarea" className={`shadow-lg shadow-black md:mx-[10%] w-[100%] h-[20vh] border-none text-left align-top mb-5`} placeholder="Text" onChange={(e) => handlerText(e)} type="text" required />
              </div>
              <div className="flex w-[100%] justify-start items-center" onClick={(e) => { handlerFile(e) }}>
                <label className="w-[70%] text-black font-bold text-right " htmlFor="">File</label>
                <img src={inputImg} className="w-auto max-h-[10vh] ml-[10vw] bg-white p-[1rem] rounded" alt="" />
                <input className="shadow-lg shadow-black md:mx-[10%] w-[100%] hidden" id="formInputFile" type="file" onChange={(e) => { handlerFileOnChange(e) }} />
              </div>
              <div>
                {fileData !== null && (
                  <div className="flex justify-center items-center w-[100%]">
                    <img className="rounded shadow-md shadow-black opacity-50 hover:opacity-90 w-auto max-h-[20vh]" src={URL.createObjectURL(fileData)} alt="" />
                  </div>
                )}
              </div>
              <div className="grid grid-cols-1 md:flex w-[100%] justify-center items-center">
                <input className="shadow-lg shadow-black md:mx-[10%] w-[30%] mx-[35%] bg-white rounded my-[4vw]" type="submit" />
              </div>
            </form>
          </div>
        </div>
      ) : (
        <div className="w-[100%] min-h-[10vh] grid grid-cols-1 my-[5vh] bg-black rounded p-3">
          <div className="flex justify-center items-center mb-[4vh]">
            <h1 className="w-[100%] text-center text-3xl text-white font-bold">You need to Login if you want to comment under or if you want to Like this Post !</h1>
          </div>
          <div className="flex justify-center items-center">
            <a className="bg-red md:w-[10%] min-w-full text-center p-4 inline-block text-white text-2xl rounded opacity-90 hover:opacity-100 hover:shadow-lg hover:shadow-white" href="/sign">Sing Or Login</a>
          </div>
        </div>
      )}
    </>
  );
}
