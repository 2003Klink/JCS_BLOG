import React from 'react'
import Navbar from "../Navbar/Navbar"
import TopBlogger from "../TopBlogger/TopBlogger";
import AllBlogger from "../AllBlogger/allBlogger";
import Faq from '../Faq/FaqElement.jsx';
import Kep from "../../assets/porsche.jpg"
import PostViewOnHome from "../Post/PostViewOnHome.jsx"
const Home = () => {
  return (
    <>
    <Navbar/>
    <TopBlogger/>
    <PostViewOnHome><div>Helloka</div><div>Helloka</div><div>Helloka</div><div>Helloka</div></PostViewOnHome>
    <img src={Kep} className=' object-cover h-[100vh] md:object-fill md:w-screen md:h-auto opacity-80 ' alt="" /> 
    <AllBlogger />
    <Faq/>
    
    </>
    
  )
}

export default Home