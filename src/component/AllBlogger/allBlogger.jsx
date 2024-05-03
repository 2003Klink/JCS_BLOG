import React, { useEffect, useState } from 'react'
import dataHandler from '../../config/http'
import account from "../../assets/account.png"
import baseFun from '../../config/baseFun';
const allBlogger = () => {

  const [user,setuser] = useState([]);
  const [userWheneLogin,setUserWheneLogin] = useState([]);
  const handlerFollow = (e,{id})=>{
    e.preventDefault();
    console.log(id);
    e.currentTarget.classList.add("bg-green-500");
    e.currentTarget.classList.remove("bg-red");

    dataHandler.postDataAndHandle("createFollow",{follow:id}).then(res=>{
      console.log(res);
    }).catch(err=>{
      console.log(err);
    })
  }
  useEffect(()=>{
    dataHandler.postDataAndHandle("getUserByUsername",{username:""}).then(res=>{
      if (Array.isArray(res.data)) {
        setuser(res.data)
      }
    }).catch(err=>{
      console.log(err);
    })
    baseFun.isLogin() && dataHandler.postDataAndHandle("getUserByUserIdWithOutFriend",{}).then(res=>{
      if (Array.isArray(res.data)) {
        setUserWheneLogin(res.data)
      }
    }).catch(err=>{
      console.log(err);
    })
  },[])
  return (
    <div className=''>
        <div className='grid grid-cols-1'>
          <div className='flex  w-[90vw] mr-[5vw] ml-[5vw] mt-[2vw] mb-[2vw] bg-red min-h-[50vh] overflow-auto rounded-md' style={{scrollbarColor: "red",boxShadow: '0px 0px 10px 10px rgba(0, 0, 0, 0.5)'}}>
            {baseFun.isLogin()? 
            
            Array.isArray(userWheneLogin) &&  userWheneLogin.map((item,index)=>{
              //console.log(item.url);;
              return (<div 
                key={"userKey"+index}
                className='grid grid-cols-1 items-center min-w-[85vw] md:min-w-[30vw]  '
              >
                <div  className="flex justify-center items-center">
                  <div className='grid grid-cols-1 bg-white rounded-md w-[85vw] md:w-[30vw] m-4 min-h-[40vh]' style={{ boxShadow: '5px 5px 10px 2px rgba(0, 0, 0, 0.5)' }} >
                    <div className='pr-[2vw] pl-[2vw] pt-[2vh] pb-[2vh] rounded-md  flex justify-center items-center'>

                      <img style={{ boxShadow: '5px 5px 10px 2px rgba(0, 0, 0, 0.5)' }} className={`rounded-full w-[80vh] md:w-[10vw] h-[20vh] object-contain ${item.url !== null ? 'bg-black' : 'bg-white'}`}  src={item.url !== null ? account : item.url}/>

                    </div>
                    <div className={`${item.level === "User"?"bg-gray":"bg-red"} pr-[2vw] pl-[2vw] pt-[2vh] pb-[2vh] rounded-md`}>

                      <div className='text-2xl text-center text-white font-bold' >{item.username}</div>

                    </div>
                    <div className='w-[100%] min-h-[15vh] flex justify-around items-center p-5'>
                    <a className='rounded bg-red text-2xl text-white font-bold p-2 m-2' href={`/user#${item.id}`}>Check</a>
                    {baseFun.isLogin() && 
                      <button type='button' onClick={(e)=>{handlerFollow(e,item)}} className='rounded bg-red text-2xl text-white font-bold p-2 m-2'> Add </button>
                    }
                    </div>
                  </div>
                  
                </div>
                
                
              </div>)
            })

            : Array.isArray(user) && user.map((item,index)=>{
              //console.log(item.url);;
              return (<div 
                key={"userKey"+index}
                className='grid grid-cols-1 items-center min-w-[85vw] md:min-w-[30vw]  '
              >
                <div  className="flex justify-center items-center">
                  <div className='grid grid-cols-1 bg-white rounded-md w-[85vw] md:w-[30vw] m-4 min-h-[40vh]' style={{ boxShadow: '5px 5px 10px 2px rgba(0, 0, 0, 0.5)' }} >
                    <div className='pr-[2vw] pl-[2vw] pt-[2vh] pb-[2vh] rounded-md  flex justify-center items-center'>

                      <img style={{ boxShadow: '5px 5px 10px 2px rgba(0, 0, 0, 0.5)' }} className={`rounded-full w-[80vh] md:w-[10vw] h-[20vh] object-contain ${item.url !== null ? 'bg-white' : 'bg-black'}`}  src={item.url !== null ?  item.url : account}/>

                    </div>
                    <div className={`${item.level === "User"?"bg-gray":"bg-red"} pr-[2vw] pl-[2vw] pt-[2vh] pb-[2vh] rounded-md`}>

                      <div className='text-2xl text-center text-white font-bold' >{item.username}</div>

                    </div>
                    <div className='w-[100%] min-h-[15vh] flex justify-around items-center p-5'>
                    <a className='rounded bg-red text-2xl text-white font-bold p-2 m-2' href={`/user#${item.id}`}>Check</a>
                    {baseFun.isLogin() && 
                      <button type='button' onClick={(e)=>{handlerFollow(e,item)}} className='rounded bg-red text-2xl text-white font-bold p-2 m-2'> Add </button>
                    }
                    </div>
                  </div>
                  
                </div>
                
                
              </div>)
            })}
          </div>

        </div>
    </div>
  )
}

export default allBlogger