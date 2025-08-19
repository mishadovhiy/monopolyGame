<?php
//emailTo

$emailTitle =(isset($_GET['emailTitle'])) ? $_GET['emailTitle'] : "-";
$emailHead =(isset($_GET['emailHead'])) ? $_GET['emailHead'] : "-";
$emailBody =(isset($_GET['emailBody'])) ? $_GET['emailBody'] : "-";
//(isset($_POST["emailTo"])) ? $_POST["name"] : ""; 
//$Code = $_POST['Code'];

$to = "developer@mishadovhiy.com";
$subject = $emailTitle;
$from = "Budget Tracker User <BudgetTracker@mishadovhiy.com>";
 
// To send HTML mail, the Content-type header must be set
$headers  = 'MIME-Version: 1.0' . "\r\n";
$headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
 
// Create email headers
$headers .= 'From: '.$from."\r\n".
    'Reply-To: '.$from."\r\n" .
    'X-Mailer: PHP/' . phpversion();
 
// Compose a simple HTML email message
//$message = '<html><body>';
//$message .= '<h1 style="color:#f40; font-family:Open Sans">Hello!</h1>';
//$message .= '<h1 style="color:#f40;font-family:Open Sans">Password reset for username: <b>'.$Nickname.'</b></h1>';
//$message .= '<h1 style="color:#080;font-size:28px;">'.$resetCode.'</h1>';
//$message .= '<p1 style="font-size:12px;">Enter this code to restore password</p1>';
//$message .= '</body></html>';
$message .= '<html>
<body style="">
	<div style="position: relative; border-radius: 2px;max-width: 600px;">
		<div class="header">
		    <p style="color: #262626; font-size: 15px;">'.$emailHead.'</p>
		</div>
		<h1 style="text-align: center; margin: 0; margin-bottom: 40px; margin-top: 40px;color: #262626;">'.$emailTitle.'</h1>



<textarea style="width: 100%; height: 500px; min-width: 100%; border: none; font-size:14px;">
	'.$emailBody.'
</textarea>



		<div class="footer">
			<div style="">
				<div style="margin-right: 20px; margin-left: 20px;">
			</div>
				<div style="text-align: center;">
				<p style="font-size: 12px; color: #343434;">Budget Tracker</p></div>
			</div>
		</div>
	</div>
</body>
</html>';
 
// Sending email
if(mail($to, $subject, $message, $headers)){
    echo '1';
} else{
    echo 'Unable to send email. Please try again.';
}
?>




