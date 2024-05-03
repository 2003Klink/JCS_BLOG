import React from "react";
import message from "../../assets/message.png"
import MessageBox from "./MessageBox.jsx"
export default function Message() {
    const [modalIsOpen, setIsOpen] = React.useState(false);

    function closeModal() {
        setIsOpen(false);
      }
      function openModal() {
        console.log("Open Modal");
        setIsOpen(true);

      }



    return(
        <>
    <div className="fixed bottom-2 w-[100%] text-right z-50 ">
        <button onClick={openModal} className="bg-white hover:bg-red-400 rounded-full  border-dashed border-2 border-red-700 px-6 py-3 ">
            <img src={message} className="md:w-[3vw] w-[10vw]" />
        </button>
    </div>
    <MessageBox modalIsOpen={modalIsOpen}  closeModal={closeModal}/>
    </>)

}