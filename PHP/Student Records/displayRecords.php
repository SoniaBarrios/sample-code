<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
	<title>Display Student Records</title>
</head>

<body>
	<?php
		//error_reporting(E_ALL);
		date_default_timezone_set("America/Montreal");		//set the current timezone
		
		require("dbFunctions.php");							//get function definitions
		$conn = connectToDatabase();						//make database connection
		
		$studentID = $_POST["studentID"];					//get requested student ID number
		$studentName = getStudentName($conn,$studentID);	//get name of student
		$courseGrades = getStudentGrades($conn,$studentID);	//get name of course and associated grade for a given student
		
		$conn->close();										//close database connection
	?>
    
    <!--container for bootstrap table-->
    <div class="container">
    	<h2><?php echo $studentName; ?></h2>
        <p>Academic records for <?php echo date("Y"); ?>.</p>
        <div class="table-responsive">
        	<table class="table">
            	<thead>
                	<tr>
                    	<th>Course</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
				<?php
                    
                    //only fetch array if there are rows returned
                    if($courseGrades->num_rows > 0) {
                        while($row = $courseGrades->fetch_assoc()) {
                            echo "<tr>";
                            	echo "<td>" . $row["Course"] . "</td>";
                            	echo "<td>" . $row["Grade"] . "</td>";
                            echo "</tr>";
                        } //end while loop
                    } //end if statement
                    
                ?>
                </tbody>
            </table>
        </div>
    </div>
    
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
	<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
</body>
</html>