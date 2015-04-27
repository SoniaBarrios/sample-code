<?php
	//DESCRIPTION:	create a database object and make a connection
	//ARGUMENTS		none
	//RETURNS:		returns the database object, which is passed to functions as needed
	function connectToDatabase() {
		$servername = "xx.xx.xx.xxx";
		$username = "xxxxxx";
		$password = "xxxxxx";
		$dbname = "xxxxxx";
				
		//create connection
		$conn = new MySQLi($servername,$username,$password,$dbname);
				
		//check connection
		if($conn->connect_error) {
			die("Connection failed: " . $conn->connect_error);
		}
		
		//return the database object
		return $conn;
	}

	//DESCRIPTION:	get student's names from database and store in $studentNames
	//ARGUMENTS:	a mysqli database object as an argument
	//RETURNS:		an associative array consisting of student names, identified by a key (which is their id #)
	function getStudentNames($conn) {
		$sql = "SELECT * FROM students;";
		$result = $conn->query($sql);
		
		//only fetch array if there are rows returned
		if($result->num_rows > 0) {
			//get each row and store the names in the studentNames array by id number
			while($row = $result->fetch_assoc()) {
				$studentNames[$row["id"]] = $row["firstname"] . " " . $row["lastname"];
			}
		}
				
		//return the student's names in an array by ID number
		return $studentNames;
	}
	
	//DESCRIPTION:	retrieves the grades for all courses for a specified student
	//ARGUMENTS:	a mysqli database object and a student identified by ID number
	//RETURNS:		an associative array consisting of a list of courses and associated grades for a student
	function getStudentGrades($conn, $studentID) {
		$sql = 	"SELECT courses.name as Course, student_course.grade as Grade
					FROM student_course INNER JOIN courses
					WHERE student_course.sid=" . $studentID . " 
					and student_course.cid=courses.id;";
		
		//return the list of courses and grades for the student requested
		return $conn->query($sql);
	}
	
	//DESCRIPTION:	gets a student's full name according to the student ID number associated with it
	//ARGUMENTS:	a mysqli database object and a student identified by ID number
	//RETURNS: 		a string consisting of a student's full name
	function getStudentName($conn, $studentID) {
		$sql = 	"SELECT firstname, lastname
					FROM students 
					WHERE id=" . $studentID;
		
		//retrieve the student name for the student ID requested
		$result = $conn->query($sql)->fetch_assoc();
		$name = $result["firstname"] . " " . $result["lastname"];
		
		//Return a string consisting of botht the first and last name of the student
		return $name;
	}
?>