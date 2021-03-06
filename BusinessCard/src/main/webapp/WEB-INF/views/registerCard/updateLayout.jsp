<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en" class="wide wow-animation">
<head>
<title>Connexio</title>
<meta name="format-detection" content="telephone=no">
<meta name="viewport"
	content="width=device-width, height=device-height, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<link rel="icon" href="images/favicon.ico" type="image/x-icon">
<link rel="stylesheet" type="text/css"
	href="css/css.css?family=Montserrat:400,700%7CLato:300,300italic,400,400italic,700,900%7CPlayfair+Display:700italic,900">
<link rel="stylesheet" href="css/style.css">
<link rel="stylesheet" href="css/component.css">
<style type="text/css">
.list-wide-bordered li {
	min-height: 35px;
	padding: 6px 0px;
	font-size: 13px;
}

#downbutton input[type=button] {
	padding: 6px 90px;
}

#nologo {
	background-color: #fe4a21;
}
</style>
<script type="text/javascript" src="js/jquery-3.1.1.min.js"></script>
<script type="text/javascript">
	(function(e, t, n) {
		var r = e.querySelectorAll("html")[0];
		r.className = r.className.replace(/(^|\s)no-js(\s|$)/, "$1js$2")
	})(document, window, 0);

	var canvas = null;
	var context = null;
	var file = null;
	var reader = null;
	var layout_num = -1;

	$(document).ready(function() {
		layout_num = document.getElementById("layout_num").value;

		$("input").on("keyup", cardView);
		$('input:file').on("change", cardView);
		document.getElementById("reset").onclick = canvasClear;
		document.getElementById("updateCard").onclick = imageSave;
	});

	/* 명함 clear */
	function canvasClear() {
		if (canvas != null) {
			var ctx = canvas.getContext("2d");
			ctx.clearRect(0, 0, canvas.width, canvas.height);
			canvas = null;
			$("#logo").val("");
			$("#stext")
					.html(
							"<svg xmlns='http://www.w3.org/2000/svg' width='20' height='17' viewBox='0 0 20 17'> <path d='M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z'></path></svg> <span>Choose a file…</span>");
		}
	}

	/* 카드 캔버스 이미지 던지기 */
	function imageSave() {
		var nameV = document.getElementById("name").value;
		var companyV = document.getElementById("company").value;
		var mobileV = document.getElementById("mobile").value;
		var languageV = document.getElementById("language").value;

		if (canvas == null) {
			$('#myInput').html("Please create card!");
			$("#myModal").modal();
			return;
		}
		if (nameV == null || nameV == "") {
			$('#myInput').html("Please check the name!");
			$("#myModal").modal();
			return;
		}
		if (companyV == null || companyV == "") {
			$('#myInput').html("Please check the company!");
			$("#myModal").modal();
			return;
		}
		if (mobileV == null || mobileV == "") {
			$('#myInput').html("Please check the mobile!");
			$("#myModal").modal();
			return;
		}
		if (languageV == null || languageV == "") {
			$('#myInput').html("Please check the language!");
			$("#myModal").modal();
			return;
		}

		var imageData = canvas.toDataURL("image/png");
		var loginId = document.getElementById("m_id").value;
		var cardnum = document.getElementById("cardNum").value;

		$.ajax({
			type : 'post',
			url : 'updateCanvasImage',
			dataType : 'json',
			data : {
				imageBase64 : imageData,
				m_id : loginId,
				"cardNum" : cardnum
			},
			timeout : 100000,
			async : false,
			error : function() {
				console.log("WOOPS");
			},
			success : function(res) {
				if (res.ret == 0) {
					document.getElementById("updateCardForm").submit();
					console.log("SUCCESS");
				} else {
					console.log("FAIL : " + res.msg);
				}
			}
		});
	}

	/* 명함 생성 */
	function cardView() {
		canvas = document.getElementById("myCanvas");
		context = canvas.getContext("2d");
		file = document.querySelector("input[type=file]").files[0];
		reader = new FileReader();

		/* 명함 clear */
		context.clearRect(0, 0, canvas.width, canvas.height);
		// 레이아웃 함수
		cardSelect();
	}

	function cardSelect() {
		if (layout_num == 2) {
			/* 명함 로고 */
			if (file != null) {
				reader.addEventListener("load", function() {
					var img = new Image();
					img.onload = function() {
						context.drawImage(img, 50, 35, 100, 100);
					}
					img.src = reader.result;
				}, false);

				if (file) {
					reader.readAsDataURL(file);
				}
			}

			context.font = "25px Arial";
			context.fillText(document.getElementById("name").value, 270, 70);

			context.font = "20px Arial";
			context
					.fillText(document.getElementById("company").value, 200,
							130);

			context.font = "15px Arial";
			context.fillText("영업부" + document.getElementById("depart").value,
					200, 60);
			context.fillText("부장 " + document.getElementById("position").value,
					200, 80);

			context.font = "15px Arial";
			context
					.fillText(document.getElementById("address").value, 200,
							180);
			context.fillText("Mobile | "
					+ document.getElementById("mobile").value, 200, 200);
			context.fillText("Tel | "
					+ document.getElementById("telephone").value, 200, 220);
			context.fillText("Fax | " + document.getElementById("fax").value,
					200, 240);
			context.fillText("E-mail | "
					+ document.getElementById("email").value, 200, 260);
		}//2번 if

		else if (layout_num == 3) {
			/* 명함 로고 */
			if (file != null) {
				reader.addEventListener("load", function() {
					var img = new Image();
					img.onload = function() {
						context.drawImage(img, 250, 30, 100, 100);
					}
					img.src = reader.result;
				}, false);

				if (file) {
					reader.readAsDataURL(file);
				}
			}

			context.font = "20px Arial";
			context.fillText(document.getElementById("name").value, 50, 180);

			context.font = "15px Arial";
			context.fillText("영업부" + document.getElementById("depart").value,
					50, 220);
			context.fillText("부장 " + document.getElementById("position").value,
					50, 240);

			context.font = "20px Arial";
			context.fillText(document.getElementById("company").value, 50, 270);

			context.font = "15px Arial";
			context
					.fillText(document.getElementById("address").value, 300,
							180);
			context.fillText("Mobile | "
					+ document.getElementById("mobile").value, 300, 200);
			context.fillText("Tel | "
					+ document.getElementById("telephone").value, 300, 220);
			context.fillText("Fax | " + document.getElementById("fax").value,
					300, 240);
			context.fillText("E-mail | "
					+ document.getElementById("email").value, 300, 260);
		}//3번 if

		else if (layout_num == 4) {
			/* 명함 로고 */
			if (file != null) {
				reader.addEventListener("load", function() {
					var img = new Image();
					img.onload = function() {
						context.drawImage(img, 80, 40, 100, 100);
					}
					img.src = reader.result;
				}, false);

				if (file) {
					reader.readAsDataURL(file);
				}
			}

			context.font = "20px Arial";
			context.fillText(document.getElementById("company").value, 50, 220);

			context.font = "15px Arial";
			context
					.fillText(document.getElementById("address").value, 250,
							220);
			context.fillText("Tel | "
					+ document.getElementById("telephone").value, 250, 240);
			context.fillText("Fax | " + document.getElementById("fax").value,
					400, 240);
			context.fillText("E-mail | "
					+ document.getElementById("email").value, 250, 260);

			context.font = "15px Arial";
			context.fillText("부장 " + document.getElementById("position").value,
					300, 140);
			context.fillText("영업부 " + document.getElementById("depart").value,
					350, 140);

			context.font = "35px Arial";
			context.fillText(document.getElementById("name").value, 420, 140);

			context.font = "20px Arial";
			context.fillText("Mobile | "
					+ document.getElementById("mobile").value, 350, 180);
		}//4번 if

		else if (layout_num == 5) {
			/* 명함 로고 */
			if (file != null) {
				reader.addEventListener("load", function() {
					var img = new Image();
					img.onload = function() {
						context.drawImage(img, 400, 50, 100, 100);
					}
					img.src = reader.result;
				}, false);

				if (file) {
					reader.readAsDataURL(file);
				}
			}
			context.font = "30px Arial";
			context.fillText(document.getElementById("name").value, 50, 80);

			context.font = "15px Arial";
			context
					.fillText(document.getElementById("position").value, 50,
							110);
			context.fillText(document.getElementById("depart").value, 50, 130);

			context.font = "20px Arial";
			context
					.fillText(document.getElementById("company").value, 380,
							230);

			context.font = "15px Arial";
			context.fillText(document.getElementById("address").value, 70, 180);
			context.fillText("Mobile | "
					+ document.getElementById("mobile").value, 70, 200);
			context.fillText("Tel | "
					+ document.getElementById("telephone").value, 70, 220);
			context.fillText("Fax | " + document.getElementById("fax").value,
					70, 240);
			context.fillText("E-mail | "
					+ document.getElementById("email").value, 70, 260);
		}//5번 if

		else if (layout_num == 6) {
			/* 명함 로고 */
			if (file != null) {
				reader.addEventListener("load", function() {
					var img = new Image();
					img.onload = function() {
						context.drawImage(img, 400, 50, img.width, img.height);
					}
					img.src = reader.result;
				}, false);

				if (file) {
					reader.readAsDataURL(file);
				}
			}
			context.font = "30px Arial";
			context.fillText(document.getElementById("name").value, 50, 80);

			context.font = "15px Arial";
			context
					.fillText(document.getElementById("position").value, 50,
							110);
			context.fillText(document.getElementById("depart").value, 50, 130);

			context.font = "20px Arial";
			context
					.fillText(document.getElementById("company").value, 380,
							230);

			context.font = "15px Arial";
			context.fillText(document.getElementById("address").value, 70, 180);
			context.fillText("Mobile | "
					+ document.getElementById("mobile").value, 70, 200);
			context.fillText("Tel | "
					+ document.getElementById("telephone").value, 70, 220);
			context.fillText("Fax | " + document.getElementById("fax").value,
					70, 240);
			context.fillText("E-mail | "
					+ document.getElementById("email").value, 70, 260);
		}//6번 if
	}
</script>
</head>
<body style="">
	<div class="page">
		<%@include file="../modules/header.jsp"%>
		<main class="page-content">
		<%-- <section style="background-image: url(images/cardTypeEx/sample.jpg);"
			class="section-30 section-sm-40 section-md-66 section-lg-bottom-90 bg-gray-dark page-title-wrap">
			<div class="shell">
				<div class="page-title">
					<h2>Update ${cardType} Business Card</h2>
				</div>
			</div>
		</section> --%>
		<section class="section-60 section-sm-top-90 section-sm-bottom-100">
			<div class="shell">
				<div class="range">
					<div class="cell-md-9 cell-lg-7">
						<h3>Insert Informations</h3>
						<!-- 폼 시작 -->
						<form action="updateCardData"
							class="rd-mailform form-modern offset-top-30" method="post"
							id="updateCardForm" name="updateCardForm"
							data-form-output="form-output-global" data-form-type="order"
							enctype="multipart/form-data">
							<div class="range range-7">
								<input type="hidden" id="m_id" name="m_id" value="${card.m_id}">
								<input type="hidden" id="cardNum" name="cardNum"
									value="${card.cardNum}"> <input type="hidden"
									id="layout_num" name="layout_num" value="${card.layout_num}">
								<!--항목  -->

								<div class="cell-sm-3">
									<div class="form-group">
										<input type="text" id="name" name="name" value="${card.name}"
											data-constraints="@Required" class="form-control"> <label
											for="name" class="form-label rd-input-label">Name</label>
									</div>
								</div>

								<div class="cell-sm-3">
									<div class="form-group">
										<input type="text" id="company" name="company"
											value="${card.company}" data-constraints="@Required"
											class="form-control"> <label for="company"
											class="form-label rd-input-label">Company</label>
									</div>
								</div>

								<div class="cell-sm-3">
									<div class="form-group">
										<div>
											<input type="text" id="depart" name="depart"
												value="${card.depart}" data-constraints="@Required"
												class="form-control"> <label for="depart"
												class="form-label rd-input-label">Department</label>
										</div>
									</div>
								</div>

								<div class="cell-sm-3">
									<div class="form-group">
										<input type="text" id="position" name="position"
											value="${card.position}" data-constraints="@Required"
											class="form-control"> <label for="position"
											class="form-label rd-input-label">Position</label>
									</div>
								</div>

								<div class="cell-sm-3">
									<div class="form-group">
										<input type="text" id="address" name="address"
											value="${card.address}" data-constraints="@Required"
											class="form-control"> <label for="address"
											class="form-label rd-input-label">Address</label>
									</div>
								</div>

								<div class="cell-sm-3">
									<div class="form-group">
										<input type="email" id="email" name="email"
											value="${card.email}" data-constraints="@Email @Required"
											class="form-control"> <label for="email"
											class="form-label rd-input-label">E-mail</label>
									</div>
								</div>

								<div class="cell-sm-3">
									<div class="form-group">
										<input type="text" id="telephone" name="telephone"
											value="${card.telephone}" data-constraints="@Required"
											class="form-control"> <label for="telephone"
											class="form-label rd-input-label">Telephone</label>
									</div>
								</div>

								<div class="cell-sm-3">
									<div class="form-group">
										<input type="text" id="fax" name="fax" value="${card.fax}"
											data-constraints="@Required" class="form-control"> <label
											for="fax" class="form-label rd-input-label">Fax</label>
									</div>
								</div>

								<div class="cell-sm-3">
									<div class="form-group">
										<input type="text" id="mobile" name="mobile"
											value="${card.mobile}" data-constraints="@Required"
											class="form-control"> <label for="mobile"
											class="form-label rd-input-label">Mobile</label>
									</div>
								</div>

								<div class="cell-sm-3">
									<div id="selLan" style="font-size: 20px">
										<ul class="list-wide-bordered">
											<li><label class="radio-inline"> <input
													id="language" type="radio" name="language"
													<c:if test="${card.language eq 'eng'}">checked</c:if>
													value="eng" class="radio-custom"><span
													class="radio-custom-dummy"></span> English
											</label><label class="radio-inline"> <input id="language"
													type="radio" name="language"
													<c:if test="${card.language eq 'kor'}">checked</c:if>
													value="kor" class="radio-custom"><span
													class="radio-custom-dummy"></span> Korean
											</label><label class="radio-inline"> <input id="language"
													type="radio" name="language"
													<c:if test="${card.language eq 'jpn'}">checked</c:if>
													value="jpn" class="radio-custom"><span
													class="radio-custom-dummy"></span> Japanese
											</label></li>
										</ul>
									</div>
								</div>

								<div class="cell-sm-3 offset-top-30">
									<div class="form-group">
										<input class="inputfile inputfile-1" type="file" id="logo"
											name="logo" style="display: none;"
											data-multiple-caption="{count} files selected" multiple=""
											accept="image/*"> <label for="logo" id="stext"><svg
												xmlns="http://www.w3.org/2000/svg" width="20" height="17"
												viewBox="0 0 20 17">
											<path
													d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"></path></svg>
											<span>Choose a file…</span></label>
									</div>
								</div>

								<div class="cell-sm-3 offset-top-30" id="downbutton">
									<c:choose>
										<c:when test="${card.logoImg != null}">
											<input type="button" value="Download"
												class="btn btn-info btn-shadow btn-xs"
												onclick="location.href='downloadlogo?logoImg=${card.logoImg}&imgOriginal=${card.imgOriginal}'">
										</c:when>
										<c:otherwise>
											<input type="button" value="No Logo Image" id="nologo"
												class="btn btn-info btn-shadow btn-xs">
										</c:otherwise>
									</c:choose>
								</div>

								<div
									class="cell-xs-2 offset-top-30 offset-xs-top-30 offset-sm-top-50">
									<button type="button" id="updateCard"
										class="btn btn-primary btn-block">Update</button>
								</div>

								<div
									class="cell-xs-2 offset-top-22 offset-xs-top-30 offset-sm-top-50">
									<button type="reset" class="btn btn-silver-outline btn-block"
										id="reset" align="center">Reset</button>
								</div>
							</div>
						</form>
						<!--폼 끝  -->
					</div>
					<!-- 오른쪽 부분 -->
					<div
						class="cell-xs-2 offset-top-30 offset-xs-top-30 offset-sm-top-50">
						<canvas id="myCanvas" width="600" height="300"
							style="border: 2px solid #d3d3d3;"></canvas>
					</div>
				</div>
			</div>
		</section>
		</main>
		<%@include file="../modules/footer.jsp"%>
	</div>
	<%@include file="../modules/form-output-global.jsp"%>
	<script src="js/core.min.js"></script>
	<script src="js/script.js"></script>
	<script src="js/custom-file-input.js"></script>
	<!-- The Modal -->
	<div class="modal-open">
		<div id="myModal" class="modal">
			<!-- Modal content -->
			<div class="modal-dialog">
				<div class="modal-content">
					<br> <br>
					<div class="modal-header">
						<h3>
							Warning
							<button id="modal-close" data-dismiss="modal" class="close">
								&times;</button>
						</h3>
					</div>
					<div class="modal-body">
						<h6 id="myInput"></h6>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>