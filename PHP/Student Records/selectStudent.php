<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Select Student</title>
</head>

<body>

	<?php
    	require("dbFunctions.php");					//get function definitions
		$conn = connectToDatabase();				//make database connection
		$studentNames = getStudentNames($conn);		//retrieve names of students
		$conn->close();								//close database connection
		
    ?>
    
    <!--Create a form to select students by name-->
    <!--Pass the student's ID number to the submission page to query database-->
    <form action="displayRecords.php" method="post" id="studentsForm">
    <select name="studentID" form="studentsForm">
    <?php 
		//iterate through the array and fill the options with the student's names
		//send the id number to the records page
		foreach ($studentNames as $id=>$name) {
			echo "<option value=\"" . $id . "\">" . $name . "</option>";
		} //end foreach loop
    ?>
    </select>
    <input type="submit" />
    </form>
</body>
</html>