// baseFun.js
import Cookies from "js-cookie";


const baseFun = {
    timeSender: (startDateString) => {
        const startDate = new Date(startDateString);
        const endDate = new Date();

        const timeDifference = endDate - startDate;
        const minutesDifference = Math.floor(timeDifference / (1000 * 60));
        const hoursDifference = Math.floor(timeDifference / (1000 * 60 * 60));
        const daysDifference = Math.floor(timeDifference / (1000 * 60 * 60 * 24));

        return daysDifference > 0 ?
            `${daysDifference} napja` :
            hoursDifference > 0 ?
            `${hoursDifference} óraja` :
            minutesDifference > 0 ?
            `${minutesDifference} perce` :
            'Kevesebb, mint egy perce';
    },
    baseIP: () => { return "localhost" },
    saveUserData: ({ username, email, PPUrl }) => {
        localStorage.setItem("username", username);
        localStorage.setItem("email", email);
        localStorage.setItem("PPUrl", PPUrl);
    },
    getUserIDFromLS: () => {

        return { id: localStorage.getItem("userID"), username: localStorage.getItem("username"), email: localStorage.getItem("email"), PPUrl: localStorage.getItem("PPUrl") };
    },
    login: (jwt) => {
        Cookies.set("token", jwt);
    },
    logout: () => {

        Cookies.remove("token");
    },
    redirect: (where) => {
        window.location.href = where;
    },
    isLogin:()=>{

        if (Cookies.get("token")) {
            return true;
        }
        return false;
    },
    fileDomainChange: ({ fullUrl, findSwitch }) => {
        return fullUrl.replace(findSwitch, baseFun.baseIP());
    }
};

export default baseFun;