import React, { useState, useEffect } from 'react'

import Navbar from '../Navbar/Navbar'
import loginPNG from "../../assets/login.png"
import signupPNG from "../../assets/signup.png"
import { useNavigate } from 'react-router-dom';
import { SignUp } from './SignUp.jsx';
import { Login } from './Login.jsx';
const Sign = () => {

    const [isLogin, setIsLogin] = useState(true);

    return (
        <>
            <Navbar></Navbar>
            <div className='md:flex justify-center items-center w-screen rounded-2xl'>
                <div className={!isLogin ? "w-[100vw] md:w-[10vw] min-h-[5vh] md:min-h-[60vh] bg-gray md:rounded-ss-2xl md:rounded-es-2xl grid justify-center items-center" : "w-[100vw] md:w-[70vw] min-h-[20vh] md:min-h-[60vh] bg-red md:rounded-ss-2xl md:rounded-es-2xl grid justify-center items-center"} onClick={() => {
                    if (!isLogin) {
                        setIsLogin(!isLogin)
                    }
                }}>{isLogin ? <Login /> : <div className='grid grid-cols-1 justify-center items-center text-center text-white'><img className='h-auto w-[10vh] md:w-[15vh]' src={loginPNG}></img>LOGIN</div>}</div>
                <div className={isLogin ? "w-[100vw] md:w-[10vw] min-h-[5vh] md:min-h-[60vh] bg-gray md:rounded-ee-2xl md:rounded-se-2xl grid justify-center items-center" : "w-[100vw] md:w-[70vw] min-h-[20vh] md:min-h-[60vh] bg-red md:rounded-ee-2xl md:rounded-se-2xl grid justify-center items-center"} onClick={() => {
                    if (isLogin) {
                        setIsLogin(!isLogin)
                    }
                }}>{!isLogin ? <SignUp /> : <div className='grid grid-cols-1 justify-center items-center text-center text-white'><img className='h-auto w-[10vh] md:w-[15vh]' src={signupPNG}></img>SIGNUP</div>}</div>
            </div>
        </>
    )
}

export default Sign