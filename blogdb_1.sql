-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2024. Máj 02. 11:06
-- Kiszolgáló verziója: 10.4.32-MariaDB
-- PHP verzió: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `blogdb`
--

DELIMITER $$
--
-- Eljárások
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `createCar` (IN `name` VARCHAR(250), IN `brand` VARCHAR(250))   BEGIN
	DECLARE LastIdCar INT(11);
    IF NOT (SELECT 1 FROM cartype WHERE cartype.name = name AND cartype.brand = brand LIMIT 1) THEN
    
    	INSERT INTO cartype (cartype.name,cartype.brand)
    	VALUES(name,brand);
    	IF LAST_INSERT_ID() = LastIdCar THEN
    	SELECT "success" AS "reuslt";
    	ELSE
    	SELECT "fail" AS "reuslt";
    	END IF;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createCarXPost` (IN `postID` INT(11), IN `carID` INT(11))   BEGIN
	INSERT INTO cartypexpost(cartypexpost.postId,cartypexpost.typeID)
    VALUES (postID,carID);
   END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createEvaluation` (IN `postId` INT, IN `userId` INT)   BEGIN
DECLARE ln INT;
IF NOT EXISTS(SELECT 1 from userxposts WHERE userxposts.userID = userId AND userxposts.postID = postId) THEN
SELECT posts.like INTO ln FROM posts WHERE posts.id = postId;
UPDATE posts
SET posts.like = ln + 1
WHERE posts.id = postId;
INSERT INTO userxposts (userxposts.userID, userxposts.postID)
VALUES (userId, postId);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createFaq` (IN `name` VARCHAR(250))   INSERT INTO faq (faq.question) VALUES (name)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createFaqStep` (IN `id` INT, IN `stepNum` INT, IN `fileId` INT, IN `content` VARCHAR(250))   INSERT INTO faqstep (faqstep.FAQID,faqstep.stepNumber,faqstep.fileID,faqstep.content)
VALUES(id,stepNum,fileId,content)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createFile` (IN `name` VARCHAR(250), IN `userID` INT(11), IN `url` VARCHAR(250), IN `type` VARCHAR(250), IN `extension` VARCHAR(10), IN `size` INT(11))   BEGIN
 DECLARE modified_url VARCHAR(250);
    
    -- Eltávolítjuk a \Blog\ előtti részt a URL-ből
    SET modified_url = CONCAT('http://localhost/Blog/', SUBSTRING_INDEX(url, '\\Blog\\', -1));
INSERT INTO files(files.name,files.userID,files.url,files.type ,files.extension,files.size)
VALUES(name,userID,modified_url,type,extension,size);
SELECT files.id FROM files WHERE files.id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createFollow` (IN `follow` INT, IN `follower` INT)   BEGIN
 DECLARE follow_exists INT;
    SET follow_exists = 0;

    -- Ellenőrizzük, hogy létezik-e már ilyen követés
    SELECT COUNT(*) INTO follow_exists FROM follow WHERE follow.Follow = follow AND follow.Follower = follower;

    -- Ha nem létezik, akkor hozzáadjuk az új követést
    IF follow_exists = 0 THEN
        INSERT INTO follow (Follow, Follower) VALUES (follow, follower);
    ELSE
        CALL throwError("Follow already exists!");
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createMessage` (IN `senderId` INT, IN `receiverId` INT, IN `text` TEXT)   BEGIN
INSERT INTO message(message.text,message.senderID,message.receiverID)
VALUES(text,senderId,receiverId);

INSERT INTO notification (notification.senderID,notification.receiverID,notification.type,notification.tableID)
VALUES(senderId,receiverId,"Message",LAST_INSERT_ID());

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createNotification` (IN `senderID` INT, IN `type` VARCHAR(100), IN `tableId` INT)   BEGIN
    DECLARE cnt INT;
    DECLARE sNum INT;
    DECLARE currentOffset INT;
    DECLARE fS INT;
    SET sNum = 1;
    SET currentOffset = 0;
    
    IF type != "Post" AND !EXISTS(SELECT 1 FROM posts WHERE posts.id = tableId AND posts.postId IS NOT NULL ) THEN
    	
   
        SELECT COUNT(*) INTO cnt FROM follow WHERE follow.Follow = senderID;

        WHILE (sNum <= cnt) DO
            SELECT follow.Follower INTO fS FROM follow WHERE follow.Follow = senderID ORDER BY follow.id DESC LIMIT 1 OFFSET currentOffset;
            INSERT INTO notification (notification.senderID,notification.receiverID,notification.type,notification.tableID)
            VALUES (senderID,fS,type,tableId);
            SET sNum = sNum + 1;
            SET currentOffset = currentOffset + 1;
        END WHILE;
    END IF;
    
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createPost` (IN `InPost` INT, IN `InTitle` VARCHAR(256), IN `InText` TEXT, IN `InUserID` INT, IN `hasFile` TINYINT, IN `FileID` INT, IN `carName` VARCHAR(250), IN `carBrand` VARCHAR(250))   BEGIN
DECLARE postID INT(11);
DECLARE newPostID INT(11);

IF InPost = 0 THEN
	SET postID = NULL;
ELSE
	SET postID = InPost;
END IF;

	INSERT INTO posts(postId, title, text, userID, hasFile)
	VALUES(postID, InTitle, InText, InUserID, hasFile);

	SET newPostID = LAST_INSERT_ID();
	CALL createNotification(InUserID, "Post", newPostID);
	CALL createCar(carName, carBrand);
	CALL createCarXPost(newPostID, LAST_INSERT_ID());
    
    IF hasFile = 1 THEN
		CALL createPostXFile(newPostID,FileID);
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createPostWithFile` (IN `postId` INT, IN `title` VARCHAR(100), IN `text` TEXT, IN `userID` INT, IN `carName` VARCHAR(250), IN `carBrand` VARCHAR(250), IN `IsFile` TINYINT, IN `fileName` VARCHAR(250), IN `fileUrl` VARCHAR(250), IN `fileType` VARCHAR(250), IN `fileExtension` VARCHAR(10), IN `fileSize` INT(11))   BEGIN
    DECLARE postCount INT;
    DECLARE newPostID INT;
    DECLARE newFileID INT;
    DECLARE sendeFollowerCount INT;
    DECLARE cnt INT;
    
    SET cnt = 1;
    
    
    
    
    IF IsFile THEN 
        INSERT INTO `posts` (`postId`, `title`, `text`, `userID`,`hasFile`)
        VALUES (postId, title, text, userID,1);
        SET newPostID = LAST_INSERT_ID();
        CALL createFile(fileName,userID, fileUrl, fileType, fileExtension, fileSize);
        SET newFileID =  LAST_INSERT_ID();
        INSERT INTO postxfile(fileId, postId)
        VALUES (newFileID, newPostID);
    ELSE 
        INSERT INTO `posts` (`postId`, `title`, `text`, `userID`)
        VALUES (postId, title, text, userID);

        SET newPostID = LAST_INSERT_ID();
END IF;

    
    IF carName IS NOT NULL THEN
        CALL createCar(carName, carBrand);
        CALL createCarXPost(newPostID, LAST_INSERT_ID());
        
        SELECT COUNT(*) INTO sendeFollowerCount FROM follow WHERE follow.Follow = userID;
 		CALL createNotification(userID,"Post", newPostID);
        SELECT *
        FROM posts
        INNER JOIN cartypexpost ON posts.id = cartypexpost.postId 
        INNER JOIN cartype ON cartypexpost.typeID = cartype.id
        WHERE posts.id = newPostID;
    END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `createPostXFile` (IN `postId` INT, IN `fileId` INT)   INSERT INTO postxfile (postxfile.fileId,postxfile.postId)
VALUES (fileId,postId)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteEvaluation` (IN `postId` INT(11), IN `userId` INT(11))   BEGIN
DECLARE ln INT;
IF EXISTS(SELECT 1 from userxposts WHERE userxposts.userID = userId AND userxposts.postID = postId) THEN
SELECT posts.like INTO ln FROM posts WHERE posts.id = postId;
UPDATE posts
SET posts.like = ln - 1
WHERE posts.id = postId;
INSERT INTO userxposts (userxposts.userID, userxposts.postID)
VALUES (userId, postId);

DELETE FROM userxposts WHERE userxposts.userID = userId AND userxposts.postID = postId; 

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteMessage` (IN `userId` INT, IN `messageId` INT)   BEGIN

    IF EXISTS(SELECT 1 FROM message WHERE id = messageId AND senderID = userId) THEN 
        UPDATE message SET status = 0 WHERE id = messageId AND senderID = userId; 
        SELECT 1 AS result; 
    ELSE 
        CALL throwError("Nincs ilyen user üzenet"); 
    END IF; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllCar` ()   SELECT * from cartype$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllFaq` ()   SELECT * FROM faq$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllFriend` (IN `userId` INT)   BEGIN

SELECT 
        friend.id,
        friend.username,
        friend.email,
        friend.bio,
        friend.level,
        friendFile.url
    FROM 
        follow
    LEFT JOIN 
        user AS outUser ON (CASE WHEN follow.Follow = userId THEN follow.Follow ELSE follow.Follower END = outUser.id)
    LEFT JOIN 
        user AS friend ON (CASE WHEN follow.Follow != userId THEN follow.Follow ELSE follow.Follower END = friend.id)
    LEFT JOIN 
        files AS friendFile ON friend.profilePicture = friendFile.id
    WHERE
        outUser.id = userId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllMessageById` (IN `senderId` INT, IN `receiverId` INT)   SELECT * from message 
WHERE 
((message.senderID = senderId AND message.receiverID = receiverId)
OR
(message.senderID = receiverId AND message.receiverID =  senderId))$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllMessagesById` (IN `userId` INT, IN `friendId` INT)   BEGIN
SELECT 
        message.id,
        message.`text`,
        sender.id AS "senderId",
        sender.username AS "senderUsername",
        sender.email AS "senderEmail",
        sender.bio AS "senderBio",
        senderFile.url AS "senderUrl",
        sender.level AS "senderLevel",
        receiver.id AS "receiverId",
        receiver.username AS "receiverUsername",
        receiver.email AS "receiverEmail",
        receiver.bio AS "receiverBio",
        receiverFile.url AS "receiverUrl",
        receiver.level AS "receiverLevel",
        message.`timestamp`,
        message.`status`,
        CASE 
            WHEN message.senderID = userId THEN sender.id
            ELSE receiver.id
        END AS "check"
    FROM 
        message
    LEFT JOIN 
        user AS sender ON message.senderID = sender.id
    LEFT JOIN 
        user AS receiver ON message.receiverID = receiver.id
    LEFT JOIN 
    	files AS senderFile ON senderFile.id = sender.profilePicture
    LEFT JOIN 
    	files AS receiverFile ON receiverFile.id = sender.profilePicture
    WHERE 
        ((senderID = userId AND receiverID = friendId) OR 
        (senderID = friendId AND receiverID = userId)) AND message.status = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllPostByUserId` (IN `userId` INT(11))   SELECT posts.id,posts.title,posts.text,posts.like,posts.viewNumber,posts.timestamp,user.id AS "userId",user.username,user.email,user.bio,userFile.url,user.level FROM posts 
LEFT JOIN postxfile ON postxfile.postId= posts.id
LEFT JOIN files ON postxfile.fileId = files.id
LEFT JOIN user ON posts.userID = user.id
LEFT JOIN files AS userFile ON user.profilePicture = userFile.id
WHERE posts.userID = userId AND posts.status = 1 AND posts.postId IS NULL$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCarByCarTypeOrBrand` (IN `value` VARCHAR(250))   SELECT cartype.name , cartype.brand FROM cartype WHERE cartype.name LIKE CONCAT(CONCAT("%",value),"%") OR cartype.brand LIKE CONCAT(CONCAT("%",value),"%")$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getCommentById` (IN `postId` INT)   IF EXISTS(SELECT 1 from posts WHERE posts.id = postId AND posts.status = 1) THEN
    SELECT 	`posts`.*,
    		`user`.`username`, 
            `PPFile`.`url` AS "PPFile", 
            `postFile`.`url` AS "url"
    FROM `posts`
    LEFT JOIN `user` ON `posts`.`userID` = `user`.`id`
    LEFT JOIN `files` AS PPFile ON `user`.`profilePicture` = PPFile.`id`
    LEFT JOIN postxfile ON posts.id = postxfile.postId
    LEFT JOIN files AS postFile ON postFile.id = postxfile.fileId
    WHERE `posts`.`postId` = postId
    ORDER BY posts.timestamp DESC;
ELSE

CALL throwError("Nincs ilyen post vagy nincs engedélye");

END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFaqById` (IN `faqId` INT)   SELECT faqstep.FAQID,faq.question, faqstep.content,faqstep.stepNumber,files.url FROM faqstep
RIGHT JOIN faq ON faq.id = faqstep.FAQID
LEFT JOIN files ON faqstep.fileID = files.id
WHERE faqstep.FAQID = faqId
ORDER BY faqstep.stepNumber ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFile` (IN `fileId` INT)   SELECT * FROM files WHERE files.id = fileId$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFilesByUserId` (IN `userId` INT)   SELECT *
FROM `files`
WHERE `status` = 1
HAVING `files`.`userID` = userId$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFilesToPost` (IN `id` INT)   SELECT files.id, files.name,files.userID,files.url,files.type,files.extension,files.size,files.status 
FROM postxfile RIGHT JOIN files ON postxfile.fileId = files.id WHERE postxfile.postId = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFollowById` (IN `id` INT)   SELECT `follow`.`Follow`
FROM `follow`
WHERE `follow`.`id`   = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFollowByUserId` (IN `userId` INT(11))   BEGIN

SELECT follower.id,follower.username,follower.email,follower.bio,followerFile.url ,follower.level 
FROM follow 
LEFT JOIN user ON user.id = follow.Follower
LEFT JOIN user AS follower ON follow.Follow = follower.id
LEFT JOIN files AS followerFile ON followerFile.id = follower.profilePicture
WHERE user.id = userId AND follower.level != "Banned";

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFollowerById` (IN `id` INT)   SELECT `follow`.`Follower`
FROM `follow`
WHERE `follow`.`id`   = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getFollowerByUserId` (IN `userId` INT)   BEGIN

SELECT follower.id,follower.username,follower.email,follower.bio,followerFile.url ,follower.level 
FROM follow 
LEFT JOIN user ON user.id = follow.Follow
LEFT JOIN user AS follower ON follow.Follower = follower.id
LEFT JOIN files AS followerFile ON followerFile.id = follower.profilePicture
WHERE user.id = userId AND follower.level != "Banned";

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getHistory` (IN `userId` INT)   SELECT posts.id AS "PostId", posts.title,userviewpost.timestamp,user.username AS "postCreate",files.url AS "postCreateIMG" from posts 
LEFT JOIN userviewpost ON posts.id = userviewpost.postId 
INNER JOIN user ON posts.userID = user.id
INNER JOIN files ON files.id = user.profilePicture
WHERE userviewpost.userId = userId$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getNotificationById` (IN `userId` INT)   BEGIN

SELECT * FROM notification WHERE notification.receiverID = userId and notification.status != 0;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getPostById` (IN `postId` INT(11), IN `userId` INT(11))   BEGIN
DECLARE view int;
DECLARE user int;
SET user = userId;
	IF userId = "" THEN
    	set user = NULL;
    END IF;
IF user IS NOT NULL THEN
    IF NOT EXISTS(SELECT 1 FROM userviewpost WHERE userviewpost.userId = userID AND userviewpost.postId = postId)    THEN
        SELECT posts.viewNumber INTO view FROM posts WHERE posts.id = postId;
        UPDATE posts
        SET posts.viewNumber = view +1
        WHERE posts.id = postId;
        INSERT INTO userviewpost (userviewpost.userId,userviewpost.postId)
        VALUES(userId,postId);
    END IF;
END IF;

    SELECT
    posts.*,
    user.id as "userId" ,
    user.username,
    `userFile`.url AS 'PPUrl',
    files.url,
    (SELECT 1 from userxposts WHERE userxposts.userID = userId AND userxposts.postID = postId) AS "liked" 
    FROM posts 
    LEFT JOIN postxfile ON posts.id = postxfile.postId
    LEFT JOIN files ON files.id = postxfile.fileId
    LEFT JOIN user ON posts.userID = user.id
    LEFT JOIN files AS `userFile` ON userFile.id = user.profilePicture
    WHERE posts.id = postId; 


    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getPostSilpleModeAllOf` ()   BEGIN

SELECT *,EXISTS(SELECT 1 from userxposts WHERE userxposts.userID = userId AND userxposts.postID = postId) AS "liked" 
FROM posts
WHERE posts.status = 1;

SELECT posts.id, files.url FROM files
INNER JOIN postxfile ON postxfile.fileId = files.id
INNER JOIN posts ON postxfile.postId = posts.id
WHERE  posts.status = 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getProfilUser` (IN `userId` INT(11))   SELECT user.id AS "userId",user.username,user.email,user.bio,user.level, files.*  FROM user 
LEFT JOIN files ON files.id = user.profilePicture
WHERE user.id = userId$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getTopBlogger` ()   SELECT
user.id,
  user.username,
  user.bio,
  MAX(posts.like / posts.viewNumber) AS popularity,
  SUM(posts.viewNumber) AS totalViews,
  SUM(posts.like) AS totalLikes
FROM
  posts
INNER JOIN
  user ON user.id = posts.userID
GROUP BY
  user.username
ORDER BY
  popularity DESC, totalLikes DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserByID` (IN `id` INT)   SELECT `user`.`id`, `user`.`username`, `user`.`email`, `user`.`bio`, files.url AS 'profilePicture', `user`.`level`
FROM `user`
LEFT JOIN files ON files.id = user.profilePicture
WHERE `user`.`id` = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserByUserIdWithOutFriend` (IN `userId` INT(11))   BEGIN

  SELECT `user`.*
    FROM `user`
    WHERE `user`.`id` NOT IN (
        SELECT follow.Follow
        FROM `follow`
        WHERE follow.Follower = userId
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getUserByUsername` (IN `username` VARCHAR(100))   SELECT `user`.`id`, `user`.`username`, `user`.`email`, `user`.`bio`,files.url,files.id AS "fileid", `user`.`level`
FROM `user`
LEFT JOIN files on files.id = user.profilePicture
WHERE `user`.`username` LIKE CONCAT(CONCAT('%', username),'%')$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `login` (IN `email` VARCHAR(256), IN `password` CHAR(64))   BEGIN
    DECLARE userCount INT;

    -- Felhasználók számának ellenőrzése
    SET userCount = (SELECT COUNT(*) FROM user WHERE user.email = email AND user.passwd = password AND user.level != "Banned");

    IF userCount > 0 THEN
        -- Felhasználó adatainak lekérdezése
        SELECT user.id,user.username,user.email,user.bio,files.url AS "profilePicture", user.level 
        	FROM user
        	LEFT JOIN files ON user.profilePicture = files.id
      		WHERE user.email = email AND user.passwd = password AND user.level != "Banned";
     
    ELSE
        -- Hibakezelés, ha nincs ilyen felhasználó
        CALL throwError("Nincs Ilyen User");
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectedNotification` (IN `userId` INT, IN `notificationId` INT)   UPDATE notification SET notification.status = 0 WHERE notification.id =notificationId and 
notification.receiverID = userId$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `signup` (IN `username` VARCHAR(255), IN `email` VARCHAR(255), IN `password` CHAR(64))   BEGIN
    IF EXISTS(SELECT 1 FROM user WHERE user.email = email) > 0 THEN
    	CALL throwError("Error Email");
    ELSEIF EXISTS(SELECT 1 FROM user WHERE user.username = username) > 0 THEN
    	CALL throwError("Error UserName");
    ELSE
        -- Ha nem létezik, akkor hozd létre az új felhasználót
        INSERT INTO user (username, email, passwd) VALUES (username, email, password);
        SELECT * FROM user WHERE user.email = email;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `throwError` (IN `message` VARCHAR(255))   BEGIN
    DECLARE ErrorMessage VARCHAR(1000);
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateMessage` (IN `messageId` INT, IN `newText` VARCHAR(255), IN `userId` INT)   BEGIN

IF EXISTS(SELECT 1 FROM message WHERE message.id = messageId AND message.senderID = userId) THEN

UPDATE message SET message.text = newText WHERE message.id = messageId;

ELSE
CALL throwError("nincs ilyen id");
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateViewedNotification` (IN `notificationID` INT)   UPDATE notification
SET notification.status = 0
WHERE notification.id = notificationID$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `userUpdate` (IN `userData` JSON)   BEGIN
    DECLARE id INT(11);
    DECLARE username VARCHAR(256);
    DECLARE email VARCHAR(256);
    DECLARE passwd CHAR(64);
    DECLARE bio TEXT;
    DECLARE profilePicture INT(11);
    DECLARE level VARCHAR(256);
    
    -- Új adatok kinyerése a JSON objektumból
    SET id = JSON_UNQUOTE(JSON_EXTRACT(userData, '$.id'));
    SET username = JSON_UNQUOTE(JSON_EXTRACT(userData, '$.username'));
    SET email = JSON_UNQUOTE(JSON_EXTRACT(userData, '$.email'));
    SET passwd = JSON_UNQUOTE(JSON_EXTRACT(userData, '$.passwd'));
    SET bio = JSON_UNQUOTE(JSON_EXTRACT(userData, '$.bio'));
    SET profilePicture = JSON_UNQUOTE(JSON_EXTRACT(userData, '$.profilePicture'));
    SET level = JSON_UNQUOTE(JSON_EXTRACT(userData, '$.level'));
    
    IF id IS NOT NULL THEN
        IF username IS NOT NULL THEN
            UPDATE user SET user.username = username WHERE user.id = id;
        END IF;
        
        IF email IS NOT NULL THEN
            UPDATE user SET user.email = email WHERE user.id = id;
        END IF;
        
        IF passwd IS NOT NULL THEN
            UPDATE user SET user.passwd = passwd WHERE user.id = id;
        END IF;
        
        IF bio IS NOT NULL THEN
            UPDATE user SET user.bio = bio WHERE user.id = id;
        END IF;
        
        IF profilePicture IS NOT NULL THEN
            UPDATE user SET user.profilePicture = profilePicture WHERE user.id = id;
        END IF;
        
        IF level IS NOT NULL THEN
            UPDATE user SET user.level = level WHERE user.id = id;
        END IF;
        
        SELECT * FROM user WHERE user.id = id;
    ELSE
        CALL throwError("Miss ID");
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `cartype`
--

CREATE TABLE `cartype` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `brand` enum('Audi') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `cartypexpost`
--

CREATE TABLE `cartypexpost` (
  `id` int(11) NOT NULL,
  `postId` int(11) DEFAULT NULL,
  `typeID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `cartypexpost`
--

INSERT INTO `cartypexpost` (`id`, `postId`, `typeID`) VALUES
(1, 0, 0),
(2, 2, 2),
(3, 3, 3),
(4, 7, 4),
(5, 13, 5),
(6, 15, 6),
(7, 16, 7),
(8, 17, 8),
(9, 19, 5),
(10, 20, 6),
(11, 21, 7),
(12, 22, 9),
(13, 23, 11),
(14, 24, 13),
(15, 0, 0),
(16, 15, 15),
(17, 25, 15),
(18, 26, 17),
(19, 27, 19),
(20, 28, 21),
(21, 29, 23),
(22, 30, 25),
(23, 31, 27),
(24, 32, 29),
(25, 33, 31),
(26, 34, 33),
(27, 35, 35),
(28, 36, 37),
(29, 37, 39),
(30, 38, 41),
(31, 39, 43),
(32, 40, 45),
(33, 41, 47),
(34, 42, 49),
(35, 43, 52),
(36, 44, 55),
(37, 45, 58),
(38, 46, 61),
(39, 47, 64),
(40, 48, 65),
(41, 49, 49),
(42, 50, 94),
(43, 51, 97),
(44, 52, 100),
(45, 53, 103),
(46, 54, 106),
(47, 55, 109),
(48, 56, 127),
(49, 57, 130),
(50, 58, 133),
(51, 59, 136),
(52, 60, 139),
(53, 61, 142),
(54, 62, 146),
(55, 63, 150),
(56, 64, 154),
(57, 65, 158),
(58, 66, 162),
(59, 67, 166),
(60, 68, 170),
(61, 69, 174),
(62, 70, 178),
(63, 71, 182),
(64, 72, 186),
(65, 73, 190),
(66, 74, 194),
(67, 75, 198),
(68, 76, 202),
(69, 77, 206),
(70, 78, 210),
(71, 79, 214),
(72, 80, 80),
(73, 81, 81),
(74, 82, 82),
(75, 83, 83),
(76, 84, 84),
(77, 85, 85),
(78, 86, 86),
(79, 87, 87),
(80, 88, 88),
(81, 89, 89),
(82, 90, 90),
(83, 91, 91),
(84, 92, 92),
(85, 93, 93),
(86, 94, 94),
(87, 95, 95),
(88, 96, 96),
(89, 97, 97),
(90, 98, 98),
(91, 99, 99),
(92, 100, 100),
(93, 101, 101),
(94, 102, 102),
(95, 103, 103),
(96, 104, 104),
(97, 105, 105),
(98, 106, 106),
(99, 107, 107),
(100, 108, 108);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `faq`
--

CREATE TABLE `faq` (
  `id` int(11) NOT NULL,
  `question` varchar(1000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `faq`
--

INSERT INTO `faq` (`id`, `question`) VALUES
(1, 'How to login?'),
(3, 'How to Signup?');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `faqstep`
--

CREATE TABLE `faqstep` (
  `id` int(11) NOT NULL,
  `FAQID` int(11) DEFAULT NULL,
  `stepNumber` int(11) DEFAULT NULL,
  `fileID` int(11) DEFAULT NULL,
  `content` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `faqstep`
--

INSERT INTO `faqstep` (`id`, `FAQID`, `stepNumber`, `fileID`, `content`) VALUES
(2, 1, 1, 2, 'Click Right top button!'),
(3, 1, 2, 3, 'Write your Data!');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `files`
--

CREATE TABLE `files` (
  `id` int(11) NOT NULL,
  `name` varchar(250) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  `url` varchar(250) DEFAULT NULL,
  `type` enum('File','Image','Video') DEFAULT NULL,
  `extension` varchar(10) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `files`
--

INSERT INTO `files` (`id`, `name`, `userID`, `url`, `type`, `extension`, `size`, `status`) VALUES
(1, 'PNGKK', 1, 'http://localhost/Blog/system\\Config\\FILES\\PNGKK(0).png', 'Image', 'png', 103123412, 1),
(2, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(0).png', 'Image', 'png', 103123412, 1),
(3, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(1).png', 'Image', 'png', 103123412, 1),
(4, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(2).png', 'Image', 'png', 103123412, 1),
(5, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(3).png', 'Image', 'png', 103123412, 1),
(6, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(4).png', 'Image', 'png', 103123412, 1),
(7, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(5).png', 'Image', 'png', 103123412, 1),
(8, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(6).png', 'Image', 'png', 103123412, 1),
(9, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(7).png', 'Image', 'png', 103123412, 1),
(10, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(8).png', 'Image', 'png', 103123412, 1),
(11, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(9).png', 'Image', 'png', 103123412, 1),
(12, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(10).png', 'Image', 'png', 103123412, 1),
(13, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(11).png', 'Image', 'png', 103123412, 0),
(14, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(12).png', 'Image', 'png', 103123412, 1),
(15, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(13).png', 'Image', 'png', 103123412, 1),
(16, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(14).png', 'Image', 'png', 103123412, 1),
(17, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(15).png', 'Image', 'png', 103123412, 1),
(18, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(16).png', 'Image', 'png', 103123412, 1),
(19, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(17).png', 'Image', 'png', 103123412, 1),
(20, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(18).png', 'Image', 'png', 103123412, 1),
(21, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(19).png', 'Image', 'png', 103123412, 1),
(22, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(20).png', 'Image', 'png', 103123412, 1),
(23, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(21).png', 'Image', 'png', 103123412, 1),
(24, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(22).png', 'Image', 'png', 103123412, 1),
(25, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(23).png', 'Image', 'png', 103123412, 1),
(26, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(24).png', 'Image', 'png', 103123412, 1),
(27, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(25).png', 'Image', 'png', 103123412, 1),
(28, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(26).png', 'Image', 'png', 103123412, 1),
(29, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(27).png', 'Image', 'png', 103123412, 1),
(30, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(28).png', 'Image', 'png', 103123412, 1),
(31, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(29).png', 'Image', 'png', 103123412, 1),
(32, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(30).png', 'Image', 'png', 103123412, 1),
(33, 'img', 1, 'http://localhost/Blog/system\\Config\\FILES\\img(31).png', 'Image', 'png', 103123412, 1),
(34, 'module_table_top', 4, 'http://localhost/Blog/system\\Config\\FILES\\module_table_top(0).png', 'Image', 'png', 337, 1),
(35, 'module_table_bottom', 4, 'http://localhost/Blog/system\\Config\\FILES\\module_table_bottom(0).png', 'Image', 'png', 751, 1),
(36, 'module_table_top', 4, 'http://localhost/Blog/system\\Config\\FILES\\module_table_top(1).png', 'Image', 'png', 337, 1),
(37, 'module_table_top', 4, 'http://localhost/Blog/system\\Config\\FILES\\module_table_top(2).png', 'Image', 'png', 337, 1),
(38, 'module_table_top', 4, 'http://localhost/Blog/system\\Config\\FILES\\module_table_top(3).png', 'Image', 'png', 337, 1),
(39, 'img', 2, 'http://localhost/Blog/system\\Config\\FILES\\img(32).png', 'Image', 'png', 103123412, 1),
(40, '69FA8C12-8039-46EB-80E4-B642326FFCC7', 22, 'http://localhost/Blog/system\\Config\\FILES\\69FA8C12-8039-46EB-80E4-B642326FFCC7(0).JPG', 'Image', 'JPG', 3178750, 1),
(41, 'Képernyőkép 2024-01-08 144453', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-01-08 144453(0).png', 'Image', 'png', 1346474, 1),
(42, 'Képernyőkép 2024-01-08 144453', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-01-08 144453(1).png', 'Image', 'png', 1346474, 1),
(43, 'Képernyőkép 2024-01-11 164155', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-01-11 164155(0).png', 'Image', 'png', 48291, 1),
(44, 'Képernyőkép 2024-01-11 164220', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-01-11 164220(0).png', 'Image', 'png', 186740, 1),
(45, 'Képernyőkép 2024-01-15 070739', 4, 'http://localhost/Blog/http://localhostsystem\\Config\\FILES\\Képernyőkép 2024-01-15 070739(0).png', 'Image', 'png', 11779, 1),
(46, 'Képernyőkép 2024-01-11 164339', 4, 'http://localhost/Blog/http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-01-11 164339(0).png', 'Image', 'png', 114270, 1),
(47, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(35).png', 'Image', 'png', 103123412, 1),
(48, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(36).png', 'Image', 'png', 103123412, 1),
(49, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(37).png', 'Image', 'png', 103123412, 1),
(50, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(38).png', 'Image', 'png', 103123412, 1),
(51, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(39).png', 'Image', 'png', 103123412, 1),
(52, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(40).png', 'Image', 'png', 103123412, 1),
(53, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(41).png', 'Image', 'png', 103123412, 1),
(54, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(42).png', 'Image', 'png', 103123412, 1),
(55, 'img', 4, 'http://localhost/Blog/system\\Config\\FILES\\img(43).png', 'Image', 'png', 103123412, 1),
(56, 'Képernyőkép 2024-04-17 204854', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 204854(0).png', 'Image', 'png', 463037, 1),
(57, 'Képernyőkép 2024-04-17 204854', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 204854(1).png', 'Image', 'png', 463037, 1),
(58, 'Képernyőkép 2024-04-17 204854', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 204854(2).png', 'Image', 'png', 463037, 1),
(59, 'Képernyőkép 2024-04-17 204854', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 204854(3).png', 'Image', 'png', 463037, 1),
(60, 'Képernyőkép 2024-04-17 205350', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 205350(0).png', 'Image', 'png', 442246, 1),
(61, 'Képernyőkép 2024-04-17 205350', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 205350(1).png', 'Image', 'png', 442246, 1),
(62, 'Képernyőkép 2024-04-17 205350', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 205350(2).png', 'Image', 'png', 442246, 1),
(63, 'Képernyőkép 2024-04-17 204801', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 204801(0).png', 'Image', 'png', 380833, 1),
(64, 'Képernyőkép 2024-04-17 205733', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 205733(0).png', 'Image', 'png', 142193, 1),
(65, 'Képernyőfelvétel (1)', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőfelvétel (1)(0).png', 'Image', 'png', 1128773, 1),
(66, 'Képernyőkép 2024-04-17 205733', 4, 'http://localhost/Blog/system\\Config\\FILES\\Képernyőkép 2024-04-17 205733(1).png', 'Image', 'png', 142193, 1),
(67, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(68, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(69, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(70, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(71, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(72, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(73, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(74, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(75, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(76, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1),
(77, '81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473', 4, 'http://localhost/Blog/system\\Config\\FILES\\81700a9f28157e8941d4279633502b2e2e0588fe7d89e0df35208d5d61dc8473.png', 'Image', 'png', 1128773, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `follow`
--

CREATE TABLE `follow` (
  `id` int(11) NOT NULL,
  `Follow` int(11) DEFAULT NULL,
  `Follower` int(11) DEFAULT NULL,
  `status` tinyint(1) DEFAULT 1,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `follow`
--

INSERT INTO `follow` (`id`, `Follow`, `Follower`, `status`, `timestamp`) VALUES
(1, 1, 2, 1, '2023-12-20 14:36:25'),
(2, 1, 3, 1, '2023-12-20 14:36:25'),
(7, 2, 3, 1, '2023-12-18 15:06:21'),
(8, 4, 3, 1, '2024-01-05 14:10:47'),
(9, 4, 1, 1, '2024-01-05 14:10:47'),
(10, 4, 2, 1, '2024-01-05 14:10:47'),
(19, 2, 26, 1, '2024-05-01 16:54:35'),
(43, 1, 4, 1, '2024-05-01 19:21:48'),
(44, 2, 4, 1, '2024-05-01 19:21:50'),
(45, 3, 4, 1, '2024-05-01 19:21:51'),
(46, 4, 4, 1, '2024-05-01 19:21:52'),
(47, 5, 4, 1, '2024-05-01 19:21:54'),
(48, 6, 4, 1, '2024-05-01 19:21:55'),
(49, 7, 4, 1, '2024-05-01 19:21:56'),
(50, 8, 4, 1, '2024-05-01 19:21:57'),
(51, 9, 4, 1, '2024-05-01 19:21:58'),
(52, 10, 4, 1, '2024-05-01 19:21:59'),
(53, 11, 4, 1, '2024-05-01 19:22:00'),
(54, 12, 4, 1, '2024-05-01 19:22:02'),
(55, 14, 4, 1, '2024-05-01 21:58:39'),
(56, 13, 4, 1, '2024-05-01 21:58:49'),
(57, 15, 4, 1, '2024-05-01 21:58:52'),
(58, 25, 4, 1, '2024-05-01 21:58:59'),
(59, 22, 4, 1, '2024-05-02 05:04:01'),
(60, 24, 4, 1, '2024-05-02 05:40:40'),
(61, 26, 4, 1, '2024-05-02 05:40:48'),
(62, 16, 4, 1, '2024-05-02 05:54:55'),
(63, 17, 4, 1, '2024-05-02 08:37:34'),
(64, 18, 4, 1, '2024-05-02 08:37:34'),
(65, 19, 4, 1, '2024-05-02 08:37:35'),
(66, 20, 4, 1, '2024-05-02 08:37:36'),
(67, 23, 4, 1, '2024-05-02 08:37:38');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `links`
--

CREATE TABLE `links` (
  `id` int(11) NOT NULL,
  `link` varchar(250) DEFAULT NULL,
  `value` varchar(100) DEFAULT NULL,
  `postID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `message`
--

CREATE TABLE `message` (
  `id` int(11) NOT NULL,
  `text` text DEFAULT NULL,
  `senderID` int(11) DEFAULT NULL,
  `receiverID` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `message`
--

INSERT INTO `message` (`id`, `text`, `senderID`, `receiverID`, `timestamp`, `status`) VALUES
(1, 'Szia', 1, 2, '2023-12-20 14:36:25', 1),
(2, 'asd', 1, 3, '2023-12-20 14:36:25', 1),
(4, 'Szia Mizujs? ', 2, 1, '2023-12-20 14:36:25', 1),
(5, 'Szia szeretném tudni h hogyan...', 1, 3, '2023-12-20 16:05:52', 1),
(6, 'dsads', 4, 3, '2024-04-13 05:02:58', 0),
(7, 'hello', 3, 4, '2024-04-13 05:14:16', 1),
(8, 'Mizujs?', 3, 4, '2024-04-13 05:16:41', 1),
(9, 'hello', 3, 4, '2024-04-13 05:17:17', 1),
(10, 'hello', 3, 4, '2024-04-13 05:17:39', 1),
(11, 'hello', 3, 4, '2024-04-13 05:17:39', 1),
(12, 'hello', 3, 4, '2024-04-13 05:17:41', 1),
(13, 'hello', 3, 4, '2024-04-13 05:17:47', 1),
(14, 'dsadsa', 4, 3, '2024-04-13 10:48:49', 0),
(15, 'koko', 4, 3, '2024-04-13 10:52:45', 0),
(16, 'hello', 4, 3, '2024-04-13 10:56:51', 0),
(17, 'hello', 4, 3, '2024-04-14 20:08:09', 0),
(18, 'jiohdiofds', 4, 3, '2024-04-14 20:17:49', 0),
(19, 'dsada', 4, 3, '2024-04-15 13:23:12', 1),
(20, 'Szerbúsz', 3, 4, '2024-04-15 14:19:13', 1),
(21, 'Szerbúszű', 3, 4, '2024-04-15 14:20:05', 1),
(22, 'Szerbúsz', 3, 4, '2024-04-15 14:20:09', 1),
(23, 'Szerbúsz', 3, 4, '2024-04-15 14:20:10', 1),
(24, 'Szerbúsz', 3, 4, '2024-04-15 14:20:11', 1),
(25, 'Szerbúsz', 3, 4, '2024-04-15 14:20:11', 1),
(26, 'Szerbúsz', 3, 4, '2024-04-15 14:20:11', 1),
(27, 'Szerbúsz', 3, 4, '2024-04-15 14:20:11', 1),
(28, 'hello ka ', 4, 3, '2024-04-15 14:20:27', 1),
(29, 'jkfldjlsf', 4, 3, '2024-04-15 14:20:33', 0),
(30, 'Szopogassál kavicsot', 3, 4, '2024-04-15 14:20:48', 1),
(31, 'majd te ', 4, 3, '2024-04-15 14:21:15', 0),
(32, 'FDSFDS', 4, 3, '2024-04-20 08:39:25', 1),
(33, 'vhjvjh', 4, 3, '2024-04-22 06:57:33', 0),
(34, 'helloka', 4, 3, '2024-04-29 13:55:17', 1),
(35, 'helloka', 4, 3, '2024-04-29 13:55:23', 1),
(36, 'helloka', 4, 3, '2024-04-29 13:55:23', 1),
(37, 'helloka', 4, 3, '2024-04-29 13:55:23', 1),
(38, 'helloka', 4, 3, '2024-04-29 13:55:24', 1),
(39, 'helloka', 4, 3, '2024-04-29 13:55:24', 1),
(40, 'helloka', 4, 3, '2024-04-29 13:55:24', 1),
(41, 'helloka', 4, 3, '2024-04-29 13:55:24', 1),
(42, 'helloka', 4, 3, '2024-04-29 13:56:54', 1),
(43, 'hello', 4, 3, '2024-04-29 13:57:55', 1),
(44, 'helloa', 4, 3, '2024-04-29 13:58:05', 1),
(45, 'gzugzu', 4, 3, '2024-04-29 14:00:08', 0),
(46, 'fcz', 4, 3, '2024-04-29 17:23:01', 1),
(47, 'hello ka ', 3, 4, '2024-05-02 05:03:25', 1),
(48, 'SZia', 4, 3, '2024-05-02 05:33:49', 1),
(49, 'Hello', 3, 4, '2024-05-02 05:35:12', 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `notification`
--

CREATE TABLE `notification` (
  `id` int(11) NOT NULL,
  `senderID` int(11) DEFAULT NULL,
  `receiverID` int(11) DEFAULT NULL,
  `type` enum('Post','Message','Liked') DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `tableID` int(11) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `notification`
--

INSERT INTO `notification` (`id`, `senderID`, `receiverID`, `type`, `timestamp`, `tableID`, `status`) VALUES
(1, 1, 3, 'Post', '2024-04-13 12:00:09', 19, 0),
(2, 1, 2, 'Post', '2023-12-20 15:43:11', 19, 1),
(3, 1, 3, 'Post', '2024-04-13 12:00:11', 20, 0),
(4, 1, 2, 'Post', '2023-12-20 16:01:08', 20, 1),
(5, 1, 3, 'Message', '2023-12-20 16:05:52', 5, 1),
(6, 1, 3, 'Post', '2024-04-13 12:00:16', 21, 0),
(7, 1, 2, 'Post', '2023-12-21 13:14:55', 21, 1),
(8, 1, 3, 'Post', '2024-04-13 12:17:30', 22, 0),
(9, 1, 2, 'Post', '2024-01-05 04:31:44', 22, 1),
(10, 1, 3, 'Post', '2024-04-13 12:17:45', 23, 0),
(11, 1, 2, 'Post', '2024-01-05 04:31:59', 23, 1),
(12, 1, 3, 'Post', '2024-04-13 12:16:48', 24, 0),
(13, 1, 2, 'Post', '2024-01-05 04:32:32', 24, 1),
(14, 1, 3, 'Post', '2024-04-13 12:19:06', 25, 0),
(15, 1, 2, 'Post', '2024-01-05 04:49:52', 25, 1),
(16, 1, 3, 'Post', '2024-04-13 12:18:44', 26, 0),
(17, 1, 2, 'Post', '2024-01-05 04:50:02', 26, 1),
(18, 1, 3, 'Post', '2024-04-13 12:19:11', 27, 0),
(19, 1, 2, 'Post', '2024-01-05 04:53:07', 27, 1),
(20, 1, 3, 'Post', '2024-04-13 12:16:43', 28, 0),
(21, 1, 2, 'Post', '2024-01-05 05:03:22', 28, 1),
(22, 1, 3, 'Post', '2024-04-13 12:00:03', 29, 0),
(23, 1, 2, 'Post', '2024-01-05 05:03:40', 29, 1),
(24, 1, 3, 'Post', '2024-04-13 12:15:48', 30, 0),
(25, 1, 2, 'Post', '2024-01-05 05:05:17', 30, 1),
(26, 1, 3, 'Post', '2024-04-13 12:02:06', 31, 0),
(27, 1, 2, 'Post', '2024-01-05 05:05:33', 31, 1),
(28, 1, 3, 'Post', '2024-04-13 11:59:58', 32, 0),
(29, 1, 2, 'Post', '2024-01-05 05:36:56', 32, 1),
(30, 1, 3, 'Post', '2024-04-13 12:06:14', 33, 0),
(31, 1, 2, 'Post', '2024-01-05 12:36:01', 33, 1),
(32, 1, 3, 'Post', '2024-04-13 12:02:44', 34, 0),
(33, 1, 2, 'Post', '2024-01-05 12:36:48', 34, 1),
(34, 1, 3, 'Post', '2024-04-13 12:00:06', 35, 0),
(35, 1, 2, 'Post', '2024-01-05 12:45:34', 35, 1),
(36, 1, 3, 'Post', '2024-04-13 11:59:31', 36, 0),
(37, 1, 2, 'Post', '2024-01-05 13:02:54', 36, 1),
(38, 1, 3, 'Post', '2024-04-13 11:55:01', 37, 0),
(39, 1, 2, 'Post', '2024-01-05 13:03:58', 37, 1),
(40, 1, 3, 'Post', '2024-04-13 11:57:14', 38, 0),
(41, 1, 2, 'Post', '2024-01-05 13:04:57', 38, 1),
(42, 1, 3, 'Post', '2024-04-13 11:57:13', 39, 0),
(43, 1, 2, 'Post', '2024-01-05 13:05:16', 39, 1),
(44, 1, 3, 'Post', '2024-04-13 11:57:11', 40, 0),
(45, 1, 2, 'Post', '2024-01-05 13:06:22', 40, 1),
(46, 1, 3, 'Post', '2024-04-13 11:56:33', 41, 0),
(47, 1, 2, 'Post', '2024-01-05 13:07:28', 41, 1),
(48, 1, 3, 'Post', '2024-04-13 11:51:40', 42, 0),
(49, 1, 2, 'Post', '2024-01-05 13:09:41', 42, 1),
(50, 4, 2, 'Post', '2024-01-05 15:28:11', 43, 1),
(51, 4, 1, 'Post', '2024-01-05 15:28:11', 43, 1),
(52, 4, 3, 'Post', '2024-04-13 11:54:58', 43, 0),
(53, 4, 2, 'Post', '2024-01-05 15:30:41', 44, 1),
(54, 4, 1, 'Post', '2024-01-05 15:30:41', 44, 1),
(55, 4, 3, 'Post', '2024-04-13 11:51:36', 44, 0),
(56, 4, 2, 'Post', '2024-01-05 15:35:04', 45, 1),
(57, 4, 1, 'Post', '2024-01-05 15:35:04', 45, 1),
(58, 4, 3, 'Post', '2024-04-13 11:51:44', 45, 0),
(59, 4, 2, 'Post', '2024-01-05 15:38:17', 46, 1),
(60, 4, 1, 'Post', '2024-01-05 15:38:17', 46, 1),
(61, 4, 3, 'Post', '2024-04-13 11:51:42', 46, 0),
(62, 4, 2, 'Post', '2024-01-05 17:13:20', 47, 1),
(63, 4, 1, 'Post', '2024-01-05 17:13:20', 47, 1),
(64, 4, 3, 'Post', '2024-04-13 11:51:33', 47, 0),
(65, 2, 3, 'Post', '2024-04-13 11:37:34', 48, 0),
(66, 4, 3, 'Message', '2024-04-13 05:02:58', 6, 1),
(67, 3, 4, 'Message', '2024-04-13 05:14:16', 7, 1),
(68, 3, 4, 'Message', '2024-04-13 05:16:41', 8, 1),
(69, 3, 4, 'Message', '2024-04-13 05:17:17', 9, 1),
(70, 3, 4, 'Message', '2024-04-13 05:17:39', 10, 1),
(71, 3, 4, 'Message', '2024-04-13 05:17:39', 11, 1),
(72, 3, 4, 'Message', '2024-04-13 05:17:41', 12, 1),
(73, 3, 4, 'Message', '2024-04-13 11:31:40', 13, 1),
(74, 4, 3, 'Message', '2024-04-13 05:25:40', 14, 1),
(75, 4, 3, 'Message', '2024-04-13 10:22:33', 15, 1),
(76, 4, 3, 'Message', '2024-04-13 11:31:37', 16, 1),
(77, 4, 3, 'Message', '2024-04-14 20:08:09', 17, 1),
(78, 4, 3, 'Message', '2024-04-14 20:17:49', 18, 1),
(79, 4, 3, 'Message', '2024-04-15 13:23:12', 19, 1),
(80, 3, 4, 'Message', '2024-04-15 14:19:13', 20, 1),
(81, 3, 4, 'Message', '2024-04-15 14:20:05', 21, 1),
(82, 3, 4, 'Message', '2024-04-15 14:20:09', 22, 1),
(83, 3, 4, 'Message', '2024-04-15 14:20:10', 23, 1),
(84, 3, 4, 'Message', '2024-04-15 14:20:11', 24, 1),
(85, 3, 4, 'Message', '2024-04-15 14:20:11', 25, 1),
(86, 3, 4, 'Message', '2024-04-15 14:20:11', 26, 1),
(87, 3, 4, 'Message', '2024-04-15 14:20:11', 27, 1),
(88, 4, 3, 'Message', '2024-04-15 14:20:27', 28, 1),
(89, 4, 3, 'Message', '2024-04-15 14:20:33', 29, 1),
(90, 3, 4, 'Message', '2024-04-15 14:20:48', 30, 1),
(91, 4, 3, 'Message', '2024-04-15 14:21:15', 31, 1),
(92, 4, 2, 'Post', '2024-04-15 15:02:29', 50, 1),
(93, 4, 1, 'Post', '2024-04-15 15:02:29', 50, 1),
(94, 4, 3, 'Post', '2024-04-15 15:02:29', 50, 1),
(95, 4, 2, 'Post', '2024-04-15 15:08:19', 51, 1),
(96, 4, 1, 'Post', '2024-04-15 15:08:19', 51, 1),
(97, 4, 3, 'Post', '2024-04-15 15:08:19', 51, 1),
(98, 4, 2, 'Post', '2024-04-15 15:09:19', 52, 1),
(99, 4, 1, 'Post', '2024-04-15 15:09:19', 52, 1),
(100, 4, 3, 'Post', '2024-04-15 15:09:19', 52, 1),
(101, 4, 2, 'Post', '2024-04-15 15:10:12', 53, 1),
(102, 4, 1, 'Post', '2024-04-15 15:10:12', 53, 1),
(103, 4, 3, 'Post', '2024-04-15 15:10:12', 53, 1),
(104, 4, 2, 'Post', '2024-04-15 15:13:21', 54, 1),
(105, 4, 1, 'Post', '2024-04-15 15:13:21', 54, 1),
(106, 4, 3, 'Post', '2024-04-15 15:13:21', 54, 1),
(107, 4, 2, 'Post', '2024-04-15 15:14:22', 55, 1),
(108, 4, 1, 'Post', '2024-04-15 15:14:22', 55, 1),
(109, 4, 3, 'Post', '2024-04-15 15:14:22', 55, 1),
(110, 4, 3, 'Message', '2024-04-20 08:39:25', 32, 1),
(111, 4, 3, 'Message', '2024-04-22 06:57:33', 33, 1),
(112, 4, 3, 'Message', '2024-04-29 13:55:17', 34, 1),
(113, 4, 3, 'Message', '2024-04-29 13:55:23', 35, 1),
(114, 4, 3, 'Message', '2024-04-29 13:55:23', 36, 1),
(115, 4, 3, 'Message', '2024-04-29 13:55:23', 37, 1),
(116, 4, 3, 'Message', '2024-04-29 13:55:24', 38, 1),
(117, 4, 3, 'Message', '2024-04-29 13:55:24', 39, 1),
(118, 4, 3, 'Message', '2024-04-29 13:55:24', 40, 1),
(119, 4, 3, 'Message', '2024-04-29 13:55:24', 41, 1),
(120, 4, 3, 'Message', '2024-04-29 13:56:54', 42, 1),
(121, 4, 3, 'Message', '2024-04-29 13:57:55', 43, 1),
(122, 4, 3, 'Message', '2024-04-29 13:58:05', 44, 1),
(123, 4, 3, 'Message', '2024-04-29 14:00:08', 45, 1),
(124, 4, 3, 'Message', '2024-04-29 17:23:01', 46, 1),
(125, 4, 2, 'Post', '2024-04-30 13:51:44', 56, 1),
(126, 4, 1, 'Post', '2024-04-30 13:51:44', 56, 1),
(127, 4, 3, 'Post', '2024-04-30 13:51:44', 56, 1),
(128, 4, 2, 'Post', '2024-04-30 13:52:43', 57, 1),
(129, 4, 1, 'Post', '2024-04-30 13:52:43', 57, 1),
(130, 4, 3, 'Post', '2024-04-30 13:52:43', 57, 1),
(131, 4, 2, 'Post', '2024-04-30 13:56:21', 58, 1),
(132, 4, 1, 'Post', '2024-04-30 13:56:21', 58, 1),
(133, 4, 3, 'Post', '2024-04-30 13:56:21', 58, 1),
(134, 4, 2, 'Post', '2024-04-30 13:56:51', 59, 1),
(135, 4, 1, 'Post', '2024-04-30 13:56:51', 59, 1),
(136, 4, 3, 'Post', '2024-04-30 13:56:51', 59, 1),
(137, 4, 2, 'Post', '2024-04-30 13:56:58', 60, 1),
(138, 4, 1, 'Post', '2024-04-30 13:56:58', 60, 1),
(139, 4, 3, 'Post', '2024-04-30 13:56:58', 60, 1),
(140, 4, 2, 'Post', '2024-05-01 09:02:20', 61, 1),
(141, 4, 1, 'Post', '2024-05-01 09:02:20', 61, 1),
(142, 4, 3, 'Post', '2024-05-01 09:02:20', 61, 1),
(143, 4, 4, 'Post', '2024-05-01 22:39:29', 62, 1),
(144, 4, 2, 'Post', '2024-05-01 22:39:29', 62, 1),
(145, 4, 1, 'Post', '2024-05-01 22:39:29', 62, 1),
(146, 4, 3, 'Post', '2024-05-01 22:39:29', 62, 1),
(147, 4, 4, 'Post', '2024-05-01 22:41:08', 63, 1),
(148, 4, 2, 'Post', '2024-05-01 22:41:08', 63, 1),
(149, 4, 1, 'Post', '2024-05-01 22:41:08', 63, 1),
(150, 4, 3, 'Post', '2024-05-01 22:41:08', 63, 1),
(151, 4, 4, 'Post', '2024-05-01 22:41:38', 64, 1),
(152, 4, 2, 'Post', '2024-05-01 22:41:38', 64, 1),
(153, 4, 1, 'Post', '2024-05-01 22:41:38', 64, 1),
(154, 4, 3, 'Post', '2024-05-01 22:41:38', 64, 1),
(155, 4, 4, 'Post', '2024-05-01 22:53:55', 65, 1),
(156, 4, 2, 'Post', '2024-05-01 22:53:55', 65, 1),
(157, 4, 1, 'Post', '2024-05-01 22:53:55', 65, 1),
(158, 4, 3, 'Post', '2024-05-01 22:53:55', 65, 1),
(159, 4, 4, 'Post', '2024-05-01 22:53:55', 66, 1),
(160, 4, 2, 'Post', '2024-05-01 22:53:55', 66, 1),
(161, 4, 1, 'Post', '2024-05-01 22:53:55', 66, 1),
(162, 4, 3, 'Post', '2024-05-01 22:53:55', 66, 1),
(163, 4, 4, 'Post', '2024-05-01 22:53:55', 67, 1),
(164, 4, 2, 'Post', '2024-05-01 22:53:55', 67, 1),
(165, 4, 1, 'Post', '2024-05-01 22:53:55', 67, 1),
(166, 4, 3, 'Post', '2024-05-01 22:53:55', 67, 1),
(167, 4, 4, 'Post', '2024-05-01 22:53:56', 68, 1),
(168, 4, 2, 'Post', '2024-05-01 22:53:56', 68, 1),
(169, 4, 1, 'Post', '2024-05-01 22:53:56', 68, 1),
(170, 4, 3, 'Post', '2024-05-01 22:53:56', 68, 1),
(171, 4, 4, 'Post', '2024-05-02 03:43:53', 69, 1),
(172, 4, 2, 'Post', '2024-05-02 03:43:53', 69, 1),
(173, 4, 1, 'Post', '2024-05-02 03:43:53', 69, 1),
(174, 4, 3, 'Post', '2024-05-02 03:43:53', 69, 1),
(175, 4, 4, 'Post', '2024-05-02 03:44:19', 70, 1),
(176, 4, 2, 'Post', '2024-05-02 03:44:19', 70, 1),
(177, 4, 1, 'Post', '2024-05-02 03:44:19', 70, 1),
(178, 4, 3, 'Post', '2024-05-02 03:44:19', 70, 1),
(179, 4, 4, 'Post', '2024-05-02 03:46:27', 71, 1),
(180, 4, 2, 'Post', '2024-05-02 03:46:27', 71, 1),
(181, 4, 1, 'Post', '2024-05-02 03:46:27', 71, 1),
(182, 4, 3, 'Post', '2024-05-02 03:46:27', 71, 1),
(183, 4, 4, 'Post', '2024-05-02 03:47:48', 72, 1),
(184, 4, 2, 'Post', '2024-05-02 03:47:48', 72, 1),
(185, 4, 1, 'Post', '2024-05-02 03:47:48', 72, 1),
(186, 4, 3, 'Post', '2024-05-02 03:47:48', 72, 1),
(187, 4, 4, 'Post', '2024-05-02 03:54:03', 73, 1),
(188, 4, 2, 'Post', '2024-05-02 03:54:03', 73, 1),
(189, 4, 1, 'Post', '2024-05-02 03:54:03', 73, 1),
(190, 4, 3, 'Post', '2024-05-02 03:54:03', 73, 1),
(191, 4, 4, 'Post', '2024-05-02 04:03:41', 74, 1),
(192, 4, 2, 'Post', '2024-05-02 04:03:41', 74, 1),
(193, 4, 1, 'Post', '2024-05-02 04:03:41', 74, 1),
(194, 4, 3, 'Post', '2024-05-02 04:03:41', 74, 1),
(195, 4, 4, 'Post', '2024-05-02 04:04:57', 75, 1),
(196, 4, 2, 'Post', '2024-05-02 04:04:57', 75, 1),
(197, 4, 1, 'Post', '2024-05-02 04:04:57', 75, 1),
(198, 4, 3, 'Post', '2024-05-02 04:04:57', 75, 1),
(199, 4, 4, 'Post', '2024-05-02 05:06:28', 76, 0),
(200, 4, 2, 'Post', '2024-05-02 04:07:47', 76, 1),
(201, 4, 1, 'Post', '2024-05-02 04:07:47', 76, 1),
(202, 4, 3, 'Post', '2024-05-02 04:07:47', 76, 1),
(203, 4, 4, 'Post', '2024-05-02 04:45:55', 77, 0),
(204, 4, 2, 'Post', '2024-05-02 04:28:44', 77, 1),
(205, 4, 1, 'Post', '2024-05-02 04:28:44', 77, 1),
(206, 4, 3, 'Post', '2024-05-02 04:28:44', 77, 1),
(207, 4, 4, 'Post', '2024-05-02 04:33:00', 78, 0),
(208, 4, 2, 'Post', '2024-05-02 04:28:45', 78, 1),
(209, 4, 1, 'Post', '2024-05-02 04:28:45', 78, 1),
(210, 4, 3, 'Post', '2024-05-02 04:28:45', 78, 1),
(211, 4, 4, 'Post', '2024-05-02 04:32:51', 79, 0),
(212, 4, 2, 'Post', '2024-05-02 04:32:11', 79, 1),
(213, 4, 1, 'Post', '2024-05-02 04:32:11', 79, 1),
(214, 4, 3, 'Post', '2024-05-02 04:32:11', 79, 1),
(215, 3, 4, 'Message', '2024-05-02 05:03:25', 47, 1),
(216, 4, 3, 'Message', '2024-05-02 05:33:49', 48, 1),
(217, 3, 4, 'Message', '2024-05-02 05:35:12', 49, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `posts`
--

CREATE TABLE `posts` (
  `id` int(11) NOT NULL,
  `postId` int(11) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `like` int(11) NOT NULL DEFAULT 0,
  `viewNumber` int(11) DEFAULT 0,
  `userID` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` tinyint(1) NOT NULL DEFAULT 1,
  `hasFile` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `posts`
--

INSERT INTO `posts` (`id`, `postId`, `title`, `text`, `like`, `viewNumber`, `userID`, `timestamp`, `status`, `hasFile`) VALUES
(1, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 4, 1, '2024-01-05 05:37:32', 1, 0),
(2, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(3, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2023-12-20 14:36:25', 1, 0),
(4, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 0, 1, '2023-12-20 14:36:25', 1, 0),
(5, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(6, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(7, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(8, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(9, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-01-05 05:23:59', 1, 0),
(10, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 2, 1, '2023-12-20 14:36:25', 1, 0),
(11, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(12, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(13, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2024-01-05 12:11:28', 0, 0),
(14, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(15, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 1, 1, '2023-12-20 14:36:25', 1, 0),
(16, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 1),
(17, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 14:36:25', 1, 0),
(18, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-01-04 16:53:35', 1, 1),
(19, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2023-12-20 15:43:11', 1, 1),
(20, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:00:13', 1, 1),
(21, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 2, 1, '2024-04-13 12:02:03', 1, 1),
(22, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:17:30', 1, 1),
(23, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:17:45', 1, 1),
(24, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:16:48', 1, 1),
(25, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:19:09', 1, 1),
(26, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:18:44', 1, 1),
(27, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:19:18', 1, 1),
(28, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:16:43', 1, 1),
(29, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2024-01-05 05:03:40', 1, 1),
(30, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2024-01-05 05:05:17', 1, 1),
(31, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 3, 1, '2024-01-05 05:21:43', 1, 1),
(32, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-01-05 05:48:12', 1, 1),
(33, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 12:08:56', 1, 1),
(34, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-01-05 16:34:00', 1, 1),
(35, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2024-01-05 12:45:34', 1, 1),
(36, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 2, 1, '2024-04-13 11:59:33', 1, 1),
(37, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 11:56:26', 1, 1),
(38, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 1, '2024-04-13 11:58:43', 1, 1),
(39, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2024-01-05 13:05:16', 1, 1),
(40, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2024-01-05 13:06:22', 1, 1),
(41, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2024-01-05 13:07:28', 1, 1),
(42, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 1, '2024-01-05 13:09:41', 1, 1),
(43, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 2, 4, '2024-04-13 11:54:58', 1, 0),
(44, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 3, 4, '2024-01-05 16:35:53', 1, 0),
(45, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 1, 4, '2024-01-05 15:35:04', 1, 0),
(46, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 4, '2024-01-05 15:38:17', 1, 0),
(47, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 4, '2024-01-05 17:13:20', 1, 0),
(48, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 2, 2, '2024-04-13 12:12:50', 1, 1),
(49, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 22, '2024-04-13 12:12:39', 1, 0),
(50, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 4, '2024-04-15 15:02:29', 1, 0),
(51, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 4, '2024-04-15 15:08:19', 1, 0),
(52, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 0, 4, '2024-04-15 15:09:19', 1, 0),
(53, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 4, '2024-04-15 15:10:12', 1, 0),
(54, NULL, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 0, 1, 4, '2024-04-15 15:13:21', 1, 0),
(55, 1, 'What is Lorem Ipsum?', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 2, 2, 4, '2024-04-15 15:14:22', 1, 0),
(56, NULL, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 1, 2, 4, '2024-04-30 13:51:44', 1, 1),
(57, NULL, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 0, 2, 4, '2024-04-30 13:52:43', 1, 1),
(58, NULL, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 0, 1, 4, '2024-04-30 13:56:21', 1, 1),
(59, 1, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 0, 0, 4, '2024-04-30 13:56:51', 1, 1),
(60, 55, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 0, 0, 4, '2024-04-30 13:56:58', 1, 1),
(61, 55, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 0, 0, 4, '2024-05-01 09:02:20', 1, 1),
(62, 55, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 0, 0, 4, '2024-05-01 22:39:29', 1, 1),
(63, 55, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 0, 0, 4, '2024-05-01 22:41:08', 1, 1),
(64, 55, 'Kocsik', 'Nagyon szeretem ezeket az utoket mert sziiiipek', 0, 0, 4, '2024-05-01 22:41:38', 1, 1),
(65, 55, 'ffds', 'fdsfds', 0, 0, 4, '2024-05-01 22:53:55', 1, 1),
(66, 55, 'ffds', 'fdsfds', 0, 0, 4, '2024-05-01 22:53:55', 1, 1),
(67, 55, 'ffds', 'fdsfds', 0, 0, 4, '2024-05-01 22:53:55', 1, 1),
(68, 55, 'ffds', 'fdsfds', 0, 0, 4, '2024-05-01 22:53:56', 1, 1),
(69, 54, 'fdsf', 'fdsfdsf', 0, 0, 4, '2024-05-02 03:43:53', 1, 1),
(70, 54, 'dfsdsf', 'dsfdsf', 0, 0, 4, '2024-05-02 03:44:19', 1, 1),
(71, 54, 'dfsdsf', 'dsfdsf', 0, 0, 4, '2024-05-02 03:46:27', 1, 0),
(72, 54, 'dfsdsf', 'dsfdsf', 0, 0, 4, '2024-05-02 03:47:48', 1, 0),
(73, 54, 'koko', 'koko MOst jo', 0, 0, 4, '2024-05-02 03:54:03', 1, 0),
(74, 54, 'fdsf', 'dsfdsf', 0, 0, 4, '2024-05-02 04:03:41', 1, 0),
(75, 54, 'fsdfsfdsf MOST MEGINT JOOO', 'dmsaldhuasiodnbao', 0, 0, 4, '2024-05-02 04:04:57', 1, 0),
(76, 54, 'fsdfd MOSTTTTTT0', 'fdsfdsf', 0, 1, 4, '2024-05-02 04:07:47', 1, 1),
(77, 54, 'dfdsf', 'fdsfdsf', 1, 1, 4, '2024-05-02 04:28:44', 1, 1),
(78, 54, 'dfdsf', 'fdsfdsf', 0, 1, 4, '2024-05-02 04:28:45', 1, 1),
(79, 54, 'Huhujiko', 'huhujiko', 0, 0, 4, '2024-05-02 04:32:11', 1, 1),
(80, 54, 'vggf', 'fgdfgdf', 0, 0, 4, '2024-05-02 04:44:39', 1, 0),
(81, 54, 'dsads', 'fdgfdg', 0, 0, 4, '2024-05-02 04:44:58', 1, 0),
(82, 56, 'koko', 'fdsfds', 0, 0, 3, '2024-05-02 04:45:44', 1, 0),
(83, 15, 'Good Game', 'Nagyon tetszik egy a post remélem sok ilyen lesz még!! :)', 0, 0, 4, '2024-05-02 04:50:34', 1, 1),
(84, 15, 'sgfdg', 'gfdg', 0, 0, 4, '2024-05-02 04:51:48', 1, 0),
(85, 15, 'sgfdg', 'gfdg', 0, 0, 4, '2024-05-02 04:51:50', 1, 0),
(86, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:51:57', 1, 0),
(87, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:52:07', 1, 0),
(88, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:52:08', 1, 0),
(89, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:52:09', 1, 0),
(90, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:52:09', 1, 0),
(91, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:52:09', 1, 0),
(92, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:52:19', 1, 0),
(93, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:52:41', 1, 0),
(94, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:52:51', 1, 0),
(95, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:53:18', 1, 0),
(96, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:53:33', 1, 0),
(97, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:53:41', 1, 0),
(98, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:53:59', 1, 0),
(99, 15, 'gfdg', 'gfdgfd', 0, 0, 4, '2024-05-02 04:54:13', 1, 0),
(100, 15, 'dsadd', 'sad', 0, 0, 4, '2024-05-02 04:57:28', 1, 0),
(101, 15, 'dsad', 'sa', 0, 0, 4, '2024-05-02 04:58:53', 1, 0),
(102, 56, 'Add Title', 'Add Text Data', 0, 0, 4, '2024-05-02 05:29:14', 1, 1),
(103, NULL, 'Post Title', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 1, 1, 4, '2024-05-02 05:32:13', 1, 0),
(104, 103, 'Hi', 'Nice Post', 0, 0, 4, '2024-05-02 05:32:47', 1, 1),
(105, 56, 'Title', 'text', 0, 0, 4, '2024-05-02 05:52:48', 1, 1),
(106, NULL, 'Ez egy Jó cím', 'Szervusz Mizujs? van amgy a Kocsiddal remélem h szarul vagy és sokat sirsz nélükem amgy nem! :) ', 0, 1, 4, '2024-05-02 07:58:19', 1, 0),
(107, 56, 'title', 'text', 0, 0, 4, '2024-05-02 08:36:44', 1, 1),
(108, NULL, 'Car Title', 'Text', 0, 1, 4, '2024-05-02 08:39:14', 1, 0);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `postxfile`
--

CREATE TABLE `postxfile` (
  `id` int(11) NOT NULL,
  `fileId` int(11) NOT NULL,
  `postId` int(11) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `postxfile`
--

INSERT INTO `postxfile` (`id`, `fileId`, `postId`, `status`) VALUES
(1, 1, 13, 1),
(2, 2, 15, 1),
(3, 3, 16, 1),
(4, 4, 18, 1),
(5, 5, 19, 1),
(6, 6, 20, 1),
(7, 7, 21, 1),
(8, 12, 27, 1),
(9, 19, 28, 1),
(10, 20, 29, 1),
(11, 21, 30, 1),
(12, 22, 31, 1),
(13, 23, 32, 1),
(14, 24, 33, 1),
(15, 25, 34, 1),
(16, 26, 35, 1),
(17, 27, 36, 1),
(18, 28, 37, 1),
(19, 29, 38, 1),
(20, 30, 39, 1),
(21, 31, 40, 1),
(22, 32, 41, 1),
(23, 33, 42, 1),
(24, 39, 48, 1),
(25, 47, 56, 1),
(26, 48, 57, 1),
(27, 49, 58, 1),
(28, 50, 59, 1),
(29, 51, 60, 1),
(30, 52, 61, 1),
(31, 53, 62, 1),
(32, 54, 63, 1),
(33, 55, 64, 1),
(34, 56, 65, 1),
(35, 57, 66, 1),
(36, 58, 67, 1),
(37, 59, 68, 1),
(38, 60, 69, 1),
(39, 61, 70, 1),
(40, 66, 76, 1),
(41, 67, 77, 1),
(42, 68, 78, 1),
(43, 69, 79, 1),
(44, 70, 83, 1),
(45, 71, 102, 1),
(46, 73, 104, 1),
(47, 74, 105, 1),
(48, 76, 107, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `username` varchar(100) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `passwd` char(64) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `profilePicture` int(11) DEFAULT NULL,
  `level` enum('Guest','Banned','User','Admin') DEFAULT 'User'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `user`
--

INSERT INTO `user` (`id`, `username`, `email`, `passwd`, `bio`, `profilePicture`, `level`) VALUES
(1, 'lolo', 'koko@gmail.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', '', 2, 'User'),
(2, 'blogger2', 'martinkovacs@gmail.com', 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f', NULL, 33, 'User'),
(3, 'blogger3', 'martinkovacs21@gmail.com', 'dba627194bfe7aaa65502b1d5f3f52e623a5d3dda5ae853608e4568f227059f6', NULL, NULL, 'User'),
(4, 'kokololi87', 'martin@gmail.com', 'dba627194bfe7aaa65502b1d5f3f52e623a5d3dda5ae853608e4568f227059f6', NULL, 4, 'User'),
(5, 'tester79550610', 'testEmail51045978@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(6, 'tester', 'testEmail@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(7, 'tester44552976', 'testEmail36389912@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(8, 'tester91780441', 'testEmail2016703@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(9, 'tester95764592', 'testEmail88913196@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(10, 'tester92508746', 'testEmail54928888@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(11, 'tester25078437', 'testEmail80207653@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(12, 'tester86016037', 'testEmail57122457@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(13, 'tester86742630', 'testEmail72828640@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(14, 'tester90865331', 'testEmail85646613@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(15, 'tester59733033', 'testEmail35851187@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(16, 'tester14790155', 'testEmail21292165@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(17, 'tester25107443', 'testEmail96095369@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(18, 'tester96411502', 'testEmail29591759@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(19, 'tester24758703', 'testEmail80659079@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(20, 'tester16336159', 'testEmail86010219@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(22, 'Klinkout22', 'klinkusz05@gmail.com', '112a0b6fb381b06302c99f7103dc2d644962189eb5f79d5fcb9af5d634e2c26c', NULL, NULL, 'User'),
(23, 'tester83254188', 'testEmail40444848@gmail.com', '7f52811734b9dc3d29a1494e5abfed969ed026a3b026d31562bf491e774d324f', NULL, NULL, 'User'),
(24, 'huhujiko11', 'huhujikohuhujiko@gmail.com', '308e4dd1123a4f8a029578559890ae7f7d98c9ba8359fe87b109bf12378f0c3b', NULL, NULL, 'User'),
(25, 'martinmartin', 'njknlkj@gmail.com', '6f40102eb06e86531877b6bc06f7a17c8310d025c965c95f22d24a2bc760214b', NULL, NULL, 'User'),
(26, 'testUser1966', 'testUser111@gmail.com', 'dba627194bfe7aaa65502b1d5f3f52e623a5d3dda5ae853608e4568f227059f6', NULL, NULL, 'User');

--
-- Eseményindítók `user`
--
DELIMITER $$
CREATE TRIGGER `setStatusUser` AFTER UPDATE ON `user` FOR EACH ROW BEGIN

IF NEW.level = "Banned" THEN

UPDATE posts 
SET posts.status = 0
WHERE userID = NEW.id;

UPDATE follow 
SET follow.status = 0
WHERE follow.Follow = NEW.id 
OR follow.Follower = NEW.id;

UPDATE files
set files.status = 0
WHERE files.userID = NEW.id;

UPDATE message
SET message.status =0
WHERE message.senderID = NEW.id
OR message.receiverID = NEW.id;

UPDATE notification
SET notification.status = 0
WHERE notification.senderID = NEW.id
OR notification.receiverID = NEW.id;

ELSEIF NEW.level = "User" AND OLD.level = "Banned" THEN

UPDATE posts 
SET posts.status = 1
WHERE userID = NEW.id;

UPDATE follow 
SET follow.status = 1
WHERE follow.Follow = NEW.id 
OR follow.Follower = NEW.id;

UPDATE files
set files.status = 1
WHERE files.userID = NEW.id;

UPDATE message
SET message.status = 1 
WHERE message.senderID = NEW.id
OR message.receiverID = NEW.id;

UPDATE notification
SET notification.status = 1
WHERE notification.senderID = NEW.id
OR notification.receiverID = NEW.id;

END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `userlikecar`
--

CREATE TABLE `userlikecar` (
  `id` int(11) NOT NULL,
  `TypeID` int(11) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `userviewpost`
--

CREATE TABLE `userviewpost` (
  `id` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `postId` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `userviewpost`
--

INSERT INTO `userviewpost` (`id`, `userId`, `postId`, `timestamp`) VALUES
(1, 1, 1, '2023-12-20 16:42:14'),
(2, 2, 1, '2023-12-20 16:42:14'),
(3, 1, 21, '2023-12-21 13:17:13'),
(4, 1, 18, '2024-01-04 16:53:35'),
(5, 3, 31, '2024-01-05 05:06:38'),
(6, 2, 31, '2024-01-05 05:13:06'),
(7, 1, 31, '2024-01-05 05:21:43'),
(8, 1, 9, '2024-01-05 05:23:59'),
(9, 32, 1, '2024-01-05 05:37:32'),
(10, 2, 32, '2024-01-05 05:48:12'),
(11, 2, 34, '2024-01-05 16:34:00'),
(12, 1, 44, '2024-01-05 16:35:03'),
(13, 3, 44, '2024-01-05 16:35:15'),
(14, 3, 48, '2024-04-13 11:54:50'),
(15, 3, 43, '2024-04-13 11:54:58'),
(16, 3, 37, '2024-04-13 11:56:26'),
(17, 3, 38, '2024-04-13 11:58:43'),
(18, 3, 36, '2024-04-13 11:59:33'),
(19, 3, 36, '2024-04-13 11:59:33'),
(20, 3, 20, '2024-04-13 12:00:13'),
(21, 3, 21, '2024-04-13 12:02:03'),
(22, 3, 33, '2024-04-13 12:08:56'),
(23, 4, 49, '2024-04-13 12:12:39'),
(24, 4, 48, '2024-04-13 12:12:50'),
(25, 3, 28, '2024-04-13 12:16:43'),
(26, 3, 24, '2024-04-13 12:16:48'),
(27, 3, 22, '2024-04-13 12:17:30'),
(28, 3, 23, '2024-04-13 12:17:45'),
(29, 3, 26, '2024-04-13 12:18:44'),
(30, 3, 25, '2024-04-13 12:19:09'),
(31, 3, 27, '2024-04-13 12:19:18'),
(32, 4, 10, '2024-04-14 19:44:58'),
(33, 4, 10, '2024-04-14 19:44:58'),
(34, 4, 45, '2024-04-15 15:21:13'),
(35, 4, 45, '2024-04-15 15:21:13'),
(36, 4, 3, '2024-04-21 10:55:24'),
(37, 4, 3, '2024-04-21 10:55:24'),
(38, 4, 43, '2024-04-21 13:12:44'),
(39, 4, 44, '2024-04-21 13:12:56'),
(40, 4, 15, '2024-04-22 12:19:34'),
(41, 4, 53, '2024-04-22 12:19:44'),
(42, 4, 55, '2024-04-29 14:28:36'),
(43, 4, 57, '2024-04-30 13:54:56'),
(44, 4, 57, '2024-04-30 13:54:56'),
(45, 4, 56, '2024-04-30 13:55:31'),
(46, 4, 54, '2024-05-01 08:57:59'),
(47, 26, 55, '2024-05-01 16:53:44'),
(48, 26, 55, '2024-05-01 16:53:44'),
(49, 4, 58, '2024-05-01 21:29:49'),
(50, 4, 78, '2024-05-02 04:44:42'),
(51, 3, 56, '2024-05-02 04:45:36'),
(52, 4, 77, '2024-05-02 04:45:55'),
(53, 4, 76, '2024-05-02 05:06:28'),
(54, 4, 103, '2024-05-02 05:32:23'),
(55, 4, 106, '2024-05-02 07:58:28'),
(56, 4, 108, '2024-05-02 08:39:21'),
(57, 4, 108, '2024-05-02 08:39:21');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `userxposts`
--

CREATE TABLE `userxposts` (
  `id` int(11) NOT NULL,
  `userID` int(11) DEFAULT NULL,
  `postID` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `userxposts`
--

INSERT INTO `userxposts` (`id`, `userID`, `postID`, `timestamp`) VALUES
(1, 1, 1, '2023-12-20 16:25:42'),
(2, 3, 44, '2024-01-05 16:35:53'),
(17, 4, 45, '2024-04-15 15:50:05'),
(19, 4, 4, '2024-04-30 06:28:28'),
(21, 4, 55, '2024-05-01 08:40:03'),
(22, 26, 55, '2024-05-01 16:53:47'),
(23, 4, 77, '2024-05-02 04:46:07'),
(25, 4, 15, '2024-05-02 04:49:52'),
(26, 4, 103, '2024-05-02 05:33:18'),
(30, 4, 56, '2024-05-02 08:36:56');

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `cartype`
--
ALTER TABLE `cartype`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `cartypexpost`
--
ALTER TABLE `cartypexpost`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `faq`
--
ALTER TABLE `faq`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `faqstep`
--
ALTER TABLE `faqstep`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `files`
--
ALTER TABLE `files`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `follow`
--
ALTER TABLE `follow`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `links`
--
ALTER TABLE `links`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `postxfile`
--
ALTER TABLE `postxfile`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `userlikecar`
--
ALTER TABLE `userlikecar`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `userviewpost`
--
ALTER TABLE `userviewpost`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `userxposts`
--
ALTER TABLE `userxposts`
  ADD PRIMARY KEY (`id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `cartype`
--
ALTER TABLE `cartype`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `cartypexpost`
--
ALTER TABLE `cartypexpost`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT a táblához `faq`
--
ALTER TABLE `faq`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT a táblához `faqstep`
--
ALTER TABLE `faqstep`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT a táblához `files`
--
ALTER TABLE `files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT a táblához `follow`
--
ALTER TABLE `follow`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT a táblához `links`
--
ALTER TABLE `links`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `message`
--
ALTER TABLE `message`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT a táblához `notification`
--
ALTER TABLE `notification`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=218;

--
-- AUTO_INCREMENT a táblához `posts`
--
ALTER TABLE `posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=109;

--
-- AUTO_INCREMENT a táblához `postxfile`
--
ALTER TABLE `postxfile`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT a táblához `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT a táblához `userlikecar`
--
ALTER TABLE `userlikecar`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `userviewpost`
--
ALTER TABLE `userviewpost`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT a táblához `userxposts`
--
ALTER TABLE `userxposts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
