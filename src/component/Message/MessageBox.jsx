import React, { useEffect, useState } from "react";
import Modal from 'react-modal';
import dataHandler from "../../config/http";
import account from "./../../assets/account.png"
import baseFun from "../../config/baseFun";
import {
  TEDropdown,
  TEDropdownToggle,
  TEDropdownMenu,
  TEDropdownItem,
  TERipple,
} from "tw-elements-react";

export default function MessageBox({ modalIsOpen, closeModal }) {
  const [CalledUser, setCalleduser] = useState();
  const [selected, setSelected] = useState(null);
  const [friend, setFriend] = useState([]);
  const [sendFormData, setsendFormData] = useState();

  useEffect(() => {
    const intervalId = setInterval(() => {  //assign interval to a variable to clear it.
      try {
        if (selected !== null) {
          console.log(selected.id);
          dataHandler.postDataAndHandle("getAllMessagesById", { receiverId: selected.id }).then(res => {
            setCalleduser(res.data)
            console.log("Bejut ide ");
          }).catch(err => {
            console.log(err);
          });
        }


      } catch (error) {
        console.error(error);
      }
    }, 1000)

    return () => clearInterval(intervalId); //This is important

  }, [])

  useEffect(() => {
    dataHandler.postDataAndHandle("getAllFriend", {}).then(res => {

      setFriend(res.data);
      console.log(res.data);
    }).catch(err => {
      console.log(err);
    });
  }, []);
  useEffect(() => {
    try {
      dataHandler.postDataAndHandle("getAllMessagesById", { receiverId: selected.id }).then(res => {
        setCalleduser(res.data)
        console.log("Bejut ide ");
      }).catch(err => {
        console.log(err);
      });

    } catch (error) {

    }


  }, [selected]);

  const handlerDeleteText = (item) => {
    console.log(item);
    const body = { messageId: item.id }
    dataHandler.postDataAndHandle("deleteMessage", body).then(res => {

      console.log(res);
      if (!res.err) {
        try {
          dataHandler.postDataAndHandle("getAllMessagesById", { receiverId: selected.id }).then(res => {
            setCalleduser(res.data)
            console.log("Bejut ide ");
          }).catch(err => {
            console.log(err);
          });

        } catch (error) {

        }
      }

    }).catch(err => {
      console.log(err);
    })

  }
  const handlerUpdateText = (item) => {
    const textMessage = document.getElementById("textMessageId" + item.id);
    const formUpdateMessage = document.getElementById("formUpdateMessageId" + item.id);

    textMessage.classList.toggle("invisible");
    formUpdateMessage.classList.toggle("invisible");
  }
  const handleSubmitFormupdateMessage = (e, item) => {
    e.preventDefault();
    if (e.target.newText.value) {
      const body = {
        messageId: item.id,
        newText: e.target.newText.value
      }
      dataHandler.postDataAndHandle("updateMessage", body).then(res => {
        console.log(res);
        if (!res.err) {
          try {
            dataHandler.postDataAndHandle("getAllMessagesById", { receiverId: selected.id }).then(res => {
              setCalleduser(res.data)
              handlerUpdateText(item)
            }).catch(err => {
              console.log(err);
            });

          } catch (error) {

          }
        }
      })
    }
    else {
      handlerUpdateText(item)
    }
  }
  const handlerSendForm = (e) => {
    e.preventDefault();
    console.log(sendFormData);
    e.target.text.value = ""
    console.log(e.target.text.value);
    if (sendFormData !== "") {
      dataHandler.postDataAndHandle("createMessage", {
        receiverId: selected.id,
        text: sendFormData
      }).then(res => {
        setsendFormData("");

        console.log(res);
        const Lastselecked = selected;
        setSelected(false);
        setSelected(Lastselecked);
        try {
          dataHandler.postDataAndHandle("getAllMessagesById", { receiverId: selected.id }).then(res => {
            setCalleduser(res.data)
            console.log("Bejut ide ");
          }).catch(err => {
            console.log(err);
          });

        } catch (error) {

        }
      }).catch(err => {
        console.log(err);
      });
    }
  }
  return (<Modal
    isOpen={modalIsOpen}
    onRequestClose={closeModal}
  >

    <div className={`w-[100%] grid grid-cols-1 md:flex justify-center items-end ${selected ? `bg-red` : `bg-blue-200`}`}>

      {!selected && <div style={{ backgroundImage: { account } }} className="grid grid-cols-1 justify-center items-center w-[100%] h-[80vh] md:w-[50%] overflow-x-auto">
        <h1 className="text-4xl font-bold text-center bg-red w-[100%] rounded py-5 text-white border-4 border-gray-500 ">Your Friends</h1>

        {Array.isArray(friend) && friend.map((item, index) => {
          return (<button className="grid grid-cols-1 w-[100%] hover:bg-gray-400 hover:opacity-50 min-h-[20vh] justify-center items-center bg-white rounded p-5" onClick={() => setSelected({ username: item.username, id: item.id })} key={index}>
            <div className="flex justify-center items-center">
              <img className="  w-auto h-[10vh] rounded-full mx-3 bg-black" src={item.url === null ? account : item.url} />
            </div>
            <div className="flex justify-center items-center">
              <div className=" flex justify-center items-center h-auto bg-black text-white p-3 rounded text-2xl font-bold line-clamp-2">{item.username}</div>
            </div>
          </button>)
        })}
      </div>}



      {selected && <div className="grid grid-cols-1 text-center justify-center items-end w-[100%] h-[80vh]  bg-red rounded-xl  p-4 overflow-auto">
        <div className="flex justify-start items-center"><button className="bg-black ite p-5 rounded-lg text-white fixed top-10 z-50" onClick={() => { setSelected(null) }}>BACK</button></div>
        {Array.isArray(CalledUser) && CalledUser.map((item, index) => {

          return <div key={index} className="w-[100%]">
            <p className="text-gray-400 w-[100%] border-b-2 border-spacing-2 my-2 border-black rounded-full p-2 opacity-30"></p>

            {item.check === item.receiverId && <div className=" flex justify-start items-center text-left h-auto rounded-2xl bg-white w-min p-10">
              <div className="lg:me-2 text-center lg:text-xs font-bold">
                <img className="lg:rounded-full  lg:w-[5vw] lg:bg-black" src={item.receiverUrl === null ? account : item.receiverUrl} />
                {baseFun.timeSender(item.timestamp)}
              </div>
              <div className="lg:ms-5 lg:font-bold lg:px-6">{item.text}</div>

            </div>}
            {item.check === item.senderId &&
              <div className="w-[100%] flex justify-end shadow-lg ">
                <div id={"textMessageId" + item.id} className="flex justify-end items-center text-right rounded-2xl bg-white w-auto p-3 " onDoubleClick={() => { handlerUpdateText(item) }}>
                  <div className=" lg:me-5 lg:font-bold">{item.text}</div>
                  <div className="lg:me-2 text-center lg:text-xs font-bold">
                    <img className="lg:rounded-full  lg:w-[5vw] lg:bg-black" src={item.receiverUrl === null ? account : item.receiverUrl} />
                    {baseFun.timeSender(item.timestamp)}
                  </div>


                  <TEDropdown className="flex justify-center mx-4">
                    <TERipple >
                      <TEDropdownToggle className="flex bg-green-300 items-center whitespace-nowrap rounded bg-primary px-6 pb-2 pt-2.5 text-xs font-medium uppercase leading-normal text-white shadow-[0_4px_9px_-4px_#3b71ca] transition duration-150 ease-in-out hover:bg-primary-600 hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:bg-primary-600 focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] focus:outline-none focus:ring-0 active:bg-primary-700 active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.3),0_4px_18px_0_rgba(59,113,202,0.2)] motion-reduce:transition-none dark:shadow-[0_4px_9px_-4px_rgba(59,113,202,0.5)] dark:hover:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)] dark:focus:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)] dark:active:shadow-[0_8px_9px_-4px_rgba(59,113,202,0.2),0_4px_18px_0_rgba(59,113,202,0.1)]">
                        Option
                        <span className="ml-2 [&>svg]:w-5 w-2">
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path
                              fillRule="evenodd"
                              d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
                              clipRule="evenodd"
                            />
                          </svg>
                        </span>
                      </TEDropdownToggle>
                    </TERipple>

                    <TEDropdownMenu>
                      <TEDropdownItem>
                        <a href="#" onClick={() => { handlerDeleteText(item) }} className=" block w-full min-w-[160px] cursor-pointer whitespace-nowrap bg-transparent px-4 py-2 text-sm text-left font-normal pointer-events-auto text-neutral-700 hover:bg-neutral-100 active:text-neutral-800  focus:text-neutral-800 focus:outline-none active:no-underline bg-red-700">
                          Delete
                        </a>
                      </TEDropdownItem>
                      <TEDropdownItem>
                        <a href="#" onClick={() => { handlerUpdateText(item) }} className=" block w-full min-w-[160px] cursor-pointer whitespace-nowrap bg-transparent px-4 py-2 text-sm text-left font-normal pointer-events-auto text-neutral-700 hover:bg-neutral-100 active:text-neutral-800  focus:text-neutral-800 focus:outline-none active:no-underline bg-red-700">
                          Change Text
                        </a>
                      </TEDropdownItem>

                    </TEDropdownMenu>
                  </TEDropdown>
                </div>
              </div>}

            <form id={"formUpdateMessageId" + item.id} action="" className="invisible flex justify-end items-center text-right" onSubmit={(e) => { handleSubmitFormupdateMessage(e, item) }}>
              <input type="text" id="newtext" name="newText" placeholder={item.text} />
            </form>

          </div>
        })}



        <form onSubmit={handlerSendForm} className="z-30 relative bottom-0 mt-10 bg-white w-[100%] min-h-[10vh] flex justify-between items-center">
          <input type="text" name="text" className="w-[100%] h-[10vh]" onChange={(e) => {
            setsendFormData(e.target.value)
          }} />
          <input type="submit" name="submit" value="Send" />
        </form>
      </div>}

    </div>
  </Modal>)

}
Modal.setAppElement('#root');