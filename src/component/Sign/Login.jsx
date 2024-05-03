import React from 'react';
import dataHandler from "../../config/http.js";
import baseFun from '../../config/baseFun.js';

export const Login = () => {
    const state = {
        email: "",
        password: ""
    };
    const submit = (e) => {
        e.preventDefault();
        dataHandler.postDataAndHandle("login", state)
            .then(res => {
                console.log(res);
                try {
                    baseFun.saveUserData({ username: res.data[0].username, email: res.data[0].email, PPUrl: res.data[0].PPFile });
                    //console.log(res.data[0].id,res.data[0].username,res.data[0].email);
                    baseFun.login(res.JWT);
                    alert("Login ");
                    baseFun.redirect("/");
                } catch (error) {
                    alert("We do not Found Account");
                }

            })
            .catch(err => console.error(err));
    };

    return (<form className=" w-full  bg-gray my-6 p-10 rounded-2xl" onSubmit={(e) => {
        e.preventDefault();
        submit(e);
    }}>
        <div className="relative z-0 w-full md:w-[50vw] mb-5 group">
            <input onChange={(e) => { state.email = e.target.value; }} type="email" name="email" id="email" className="p-2 block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none dark:text-white dark:border-gray-600 dark:focus:border-blue-500 focus:outline-none focus:ring-0 focus:border-blue-600 peer" placeholder=" " required />
            <label htmlFor="email" className="p-2 peer-focus:font-medium absolute text-sm text-gray-500 dark:text-gray-400 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto peer-focus:text-blue-600 peer-focus:dark:text-blue-500 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">Email address</label>
        </div>

        <div className="relative z-0 w-full md:w-[50vw] mb-5 group">
            <input onChange={(e) => { state.password = e.target.value; }} type="password" name="password" id="password" className="block py-2.5 px-0 w-full text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none dark:text-white dark:border-gray-600 dark:focus:border-blue-500 focus:outline-none focus:ring-0 focus:border-blue-600 peer" placeholder=" " required />
            <label htmlFor="password" className="peer-focus:font-medium absolute text-sm text-gray-500 dark:text-gray-400 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:start-0 rtl:peer-focus:translate-x-1/4 peer-focus:text-blue-600 peer-focus:dark:text-blue-500 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6">Password</label>
        </div>



        <button type="submit" className="text-white bg-red hover:bg-red-500 focus:ring-4 focus:outline-none focus:ring-blue-300 font-medium rounded-lg text-sm w-full sm:w-auto px-5 py-2.5 text-center dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Submit</button>
    </form>);
};
