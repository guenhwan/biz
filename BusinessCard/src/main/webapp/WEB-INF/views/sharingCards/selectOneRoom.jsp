<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en" class="wide wow-animation">
<head>
<title>Sharing Room</title>
<style>
.withdrawalbutton {
	position: relative;
	background-color: #4982e5;
	border: none;
	font-size: 15px;
	color: #FFFFFF;
	padding: 5px;
	width: 200px;
	text-align: center;
	-webkit-transition-duration: 0.4s; /* Safari */
	transition-duration: 0.4s;
	text-decoration: none;
	overflow: hidden;
	cursor: pointer;
}

.withdrawalbutton:after {
	content: "";
	background: #f1f1f1;
	display: block;
	position: absolute;
	padding-top: 300%;
	padding-left: 350%;
	margin-left: -20px !important;
	margin-top: -120%;
	opacity: 0;
	transition: all 0.8s
}

.withdrawalbutton:active:after {
	padding: 0;
	margin: 0;
	opacity: 1;
	transition: 0s
}

.withdrawalbutton span {
	cursor: pointer;
	display: inline-block;
	position: relative;
	transition: 0.5s;
}

.withdrawalbutton span:after {
	content: '\00bb';
	position: absolute;
	opacity: 0;
	top: 0;
	right: -20px;
	transition: 0.5s;
}

.withdrawalbutton:hover span {
	padding-right: 25px;
}

.withdrawalbutton:hover span:after {
	opacity: 1;
	right: 0;
}
</style>
<meta name="format-detection" content="telephone=no">
<meta name="viewport"
	content="width=device-width, height=device-height, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta charset="utf-8">
<link rel="icon" href="images/favicon.ico" type="image/x-icon">
<link rel="stylesheet" type="text/css"
	href="css/css.css?family=Montserrat:400,700%7CLato:300,300italic,400,400italic,700,900%7CPlayfair+Display:700italic,900">
<link rel="stylesheet" href="css/style.css">
<script type="text/javascript" src="resources/js/jquery-3.1.1.min.js"></script>
<script>
	window.onload = function() {
		document.getElementById("searchInvite").onclick = inviteList;// 초대검색
		document.getElementById("tab4").onclick = allMember;// 구성원 클릭

		document.getElementById("tab2").onclick = loadList;
		document.getElementById("writeClick").onclick = asdf;
	}

	//초대 검색
	function inviteList() {
		var searchTitle = $("#searchTitle").val();
		var searchText = $("#searchText").val();
		$.ajax({
			type : "get",
			url : "inviteList",
			data : {
				"searchTitle" : searchTitle,
				"searchText" : searchText
			},
			success : outInviteList
		});
	}

	// 초대할 목록 보여주기
	function outInviteList(resp) {
		$("#inviteListResult").empty();
		var msg = '<table class="table table-primary">';
		msg += "<tr>";
		msg += "<td>" + "I  D" + "</td>";
		msg += "<td>" + "이 름" + "</td>";
		msg += "</tr>";
		$
				.each(
						resp,
						function(index, item) {
							msg += "<tr>";
							msg += "<td>" + item.m_id + "</td>";
							msg += "<td>" + item.m_name + "</td>";
							msg += "<td><input type='button' class='invite' target-id='" + item.m_id + "' value='초대'/></td>";
							msg += "</tr>";
						});
		msg += '</table>';
		$("#inviteListResult").html(msg);
		$("input:button.invite").on('click', invite);
	}

	// 초대 목록에서 한 사람 선택
	function invite() {
		var targetId = $(this).attr("target-id"); // 초대할 사람 선택 시 m_id 받아옴
		var url = 'invitationCard?targetId=' + targetId;
		window.open(url, "invitationCard",
				"top=200, left=400, width=300, height=500, resizable=no");
	}

	// 공유방의 구성원 목록보기
	function allMember() {
		$.ajax({
			type : "get",
			url : "allMember",
			success : outMemberList
		});
	}

	// 공유방의 구성원 목록 보여주기
	function outMemberList(resp) {
		var msg = '<table class="table table-primary">';
		msg += "<tr>";
		msg += "<td>" + "I  D" + "</td>";
		msg += "<td>" + "이 름" + "</td>";
		msg += "</tr>";
		$.each(resp, function(index, item) {
			msg += "<tr>";
			msg += "<td>" + item.M_ID + "</td>";
			msg += "<td>" + item.GRADE + "</td>";
			msg += "</tr>";
		});
		msg += '</table>';
		$("#memberList").html(msg);
	}

	//글쓰기 폼에서 글쓰기버튼을 눌렀을경우 ajax를 통해서 DB에 저장이 됨.
	function asdf() {
		alert('??');
		var board_title = $("#board_title").val();
		//var m_id = $("#m_id").val();
		var board_content = $("#board_content").val();

		var booknum = window.location.search;
		var book_num = booknum.slice(10, 11);

		$.ajax({
			url : 'board_write',
			type : 'POST',
			data : {
				book_num : book_num,
				board_title : board_title,
				board_content : board_content
			},
			success : function() {
				alert('성공했습니다.');
				$('#listView').show();
				$('#writeForm').hide();
				loadList();
			},
			error : function() {
				alert('실패');
			}

		});

	}

	//현재 게시판에 있는 리스트전체를 불러옴(book_num에 따라서 값이 다름.)
	function loadList(listB) {
		var booknum = window.location.search;
		var book_num = booknum.slice(10, 11);

		var list = '';

		$.ajax({
			url : 'listB',
			type : 'POST',
			data : {
				book_num : book_num
			},
			dataType : 'JSON',

			success : function(e) {

				for (var i = 0; i < e.length; i++) {
					list += ' <table width="100%">';
					list += ' <tr style=text-align:center>';
					list += ' <td width="73">' + e[i].boardnum + '</td>';
					list += ' <td width="379"><a href="javascript:readB('
							+ e[i].boardnum + ')">' + e[i].board_title
							+ '</a></td>';
					//	list += ' <td width="379"><a href="/readB?boardnum=' + e[i].boardnum + '">'+ e[i].board_title + '</a></td>';
					list += ' <td width="73">' + e[i].m_id + '</td>';
					list += ' <td width="164">' + e[i].inputdate + '</td>';
					list += ' <td width="58">' + e[i].board_hits + '</td>';
					list += ' </tr>';
					list += ' </table>';
				}
				$('#dataCol').html(list);

			},
			error : function(listB) {
				alert(JSON.stringify(listB));
			}

		});

	}

	//리스트에서 글쓰기 폼을 눌렀을경우 글쓰리 페이지가 나옴.
	function check(resp) {
		var test = '';
		var booknum = window.location.search;
		var book_num = booknum.slice(10, 11);

		test += ' <form id = "writeForm" align="center">';
		test += ' <input type="hidden" name="book_num" value="'+book_num+'">';
		test += ' <div id="bbsCreated">';
		test += ' <div class="bbsCreated_bottomLine">';
		test += ' <dl>';
		test += ' <dt>제&nbsp;&nbsp;&nbsp;&nbsp;목</dt>';
		test += ' <dd>';
		test += ' <input type="text" id="board_title" size="64" maxlength="100"  class="boxTF" style="border: 2px solid #5C84DC;"/>';

		test += ' </dd>';
		test += ' </dl>';
		test += ' </div>';
		/*	test += ' <div class="bbsCreated_bottomLine">';
		test += ' <dl>';
		test += ' <dt>작성자</dt>';
		test += ' <dd>';
		test += ' <input type="text" id="m_id" name="name" size="35" maxlength="20" class="boxTF"   style="border: 2px solid #5C84DC;"/>';
		test += ' </dd>';
		test += ' </dl>';
		test += ' </div>'; */
		test += ' <div id="bbsCreated_content">';
		test += ' <dl>';
		test += ' <dt>내&nbsp;&nbsp;&nbsp;&nbsp;용 </dt>';
		test += ' <dd>';
		test += ' <textarea id="board_content" cols="63" rows="10" class="boxTA"style="border: 2px solid #5C84DC;"></textarea>';
		test += ' </dd>';
		test += ' </dl>';
		test += ' </div>';
		test += ' <div id="bbsCreated_footer">';
		test += ' <dl>';
		test += ' <td>';
		test += ' <dd>';
		test += ' <div id="button">';
		test += ' <input type="button" class="btn-sm btn-primary" id="writeClick" style="margin-top:5px; margin-right:10px""  onclick="return asdf();" value="등록">';
		/* test += '<button id="writeClick" onclick="return asdf();">글쓰기</button>' */
		//test += ' <button class="btn btn-primary-outline btn-shadow" style="WIDTH: 30pt; HEIGHT: 10pt" id="writeClick" align = "center" >글쓰기</button>';
		//test += ' <button class="btn-sm btn-primary style="WIDTH: 30pt; HEIGHT: 10pt"id="cancle" align = "center"  onclick="check();">작성취소</button>';
		test += ' <input type="button" class="btn-sm btn-primary" id="cancle" onclick="return relist();" value="작성취소">';
		test += ' </div>';
		test += ' </dd>';
		test += ' </dl>';
		test += ' </table>';
		test += ' </div>';
		test += ' </form>';

		$('#writeForm').html(test);
		$('#listView').hide();

	}

	// 데이터 읽어온 곳에서 삭제를 눌렀을 경우 ajax처리로 삭제됨.
	function deletedB(boardnum) {
		var num = boardnum;
		var booknum = window.location.search;
		var book_num = booknum.slice(10, 11);

		$.ajax({
			url : 'deleteB',
			type : 'POST',
			data : {
				boardnum : num,
				book_num : book_num,
			},
			success : function() {
				alert('성공했습니다.');
				$('#listView').show();
				$('#readData').hide();
				loadList();
			},
			error : function() {
				alert('실패');
			}

		});
	}

	//글읽기 목록에서 을 눌렀을 경우 리스트로 돌아감
	function relist() {
		$('#listView').show();
		$('#readData').hide();

		loadList();
	}

	//리스트에서 게시글을 클릭하여 정보가 나오는 페이지 설정
	function readB(boardnum) {

		var read = '';
		var num = boardnum;
		alert('.....' + num);

		$
				.ajax({
					url : 'readB',
					type : 'POST',
					dataType : 'JSON',
					data : {
						boardnum : num
					},

					//success : readData,
					success : function(e) {
						alert(JSON.stringify(e));
						read += '<table align="center">';
						read += '  <tr>';
						read += ' <td>';
						read += '  <table width="100%" cellpadding="0" cellspacing="0" border="0" >';

						read += '    <tr style="background:url(images/table_mid.gif) repeat-x; text-align:"center";>';
						read += '     <td width="5"><img src="images/table_left.gif" width="5" height="30" /></td>';
						read += '   <td style="text-align:center"; "font-weight:bold">'
								+ e.board_title + '</td>';
						read += '     <td width="5"><img src="images/table_right.gif" width="5" height="30" /></td>';
						read += '    </tr>';
						read += '   </table>';
						read += '  <table width="413">';
						read += '   <tr>';
						read += '    <td width="0">&nbsp;</td>';
						read += '     <td align="center" width="76">글번호</td>';
						read += '      <td width="319">' + e.boardnum + '</td>';
						read += '      <td width="0">&nbsp;</td>';
						read += '    </tr>';

						read += ' <tr height="1" bgcolor="#dddddd"><td colspan="4" width="407"></td></tr>';
						read += '  <tr>';
						read += '    <td width="0">&nbsp;</td>';
						read += '    <td align="center" width="76">이름</td>';
						read += '   <td width="319">' + e.m_id + '</td>';

						read += '  <td width="0">&nbsp;</td>';
						read += '  </tr>';
						read += '   <tr height="1" bgcolor="#dddddd"><td colspan="4" width="407"></td></tr>';
						read += '  <tr>';
						read += '    <td width="0">&nbsp;</td>';
						read += '   <td align="center" width="76">작성일</td>';
						read += '   <td width="319">' + e.inputdate + '</td>';
						read += '    <td width="0">&nbsp;</td>';
						read += '   </tr>';

						read += '  <tr height="1" bgcolor="#dddddd"><td colspan="4" width="407"></td></tr>';
						read += '             <tr>';
						read += '   <td width="0">&nbsp;</td>';
						read += '               <td width="399" colspan="2" height="200">'
								+ e.board_content + '</td>';
						read += '              </tr>';
						read += '   <tr height="1" bgcolor="#dddddd"><td colspan="4" width="407"></td></tr>';
						read += '  <tr height="1" bgcolor="#82B5DF"><td colspan="4" width="407"></td></tr>';
						read += '  <tr align="center">';
						read += '    <td width="0">&nbsp;</td>';
						read += '   <td colspan="2" width="399">';
						read += '<input type=button class="btn-sm btn-primary" style="margin-top:5px; margin-right:10px"value="목록"  id="write"  onclick="return relist();">';
						read += '<input type=button class="btn-sm btn-primary" style="margin-top:5px; margin-right:10px"  value="수정" onclick="return updateB('
								+ e.boardnum + ')">';
						read += '<input type=button class="btn-sm btn-primary" style="margin-top:5px" value="삭제" onclick=" return deletedB('
								+ e.boardnum + ')">';
						read += '     <td width="0">&nbsp;</td>';
						read += '   </tr>';
						read += '  </table>';
						read += ' </td>';
						read += ' </tr>';
						read += '</table>';

						$('#readData').html(read);

					},
					error : function(listB) {
						alert(JSON.stringify(listB));
					}

				});
		//$('#dataCol').hide();
		$('#listView').hide();
	}

	function updateB(boardnum) {
		var num = boardnum;
		var booknum = window.location.search;
		var book_num = booknum.slice(10, 11);
		var upda = '';
		$
				.ajax({
					url : 'readB',
					type : 'POST',
					data : {
						boardnum : num,
					},
					success : function(e) {

						alert('히히..나오지?' + JSON.stringify(e))
						$('#readData').hide();

						upda += ' <form id = "updateForm" align="center">';
						upda += ' <input type="hidden" name="book_num" value="'+book_num+'">';
						upda += ' <div id="bbsCreated">';
						upda += ' <div class="bbsCreated_bottomLine">';
						upda += ' <dl>';
						upda += ' <dt>제&nbsp;&nbsp;&nbsp;&nbsp;목</dt>';
						upda += ' <dd>';
						upda += ' <input type="text" value="'+e.board_title+'" readonly="readonly" id="board_title"  size="64" maxlength="100"  class="boxTF" style="border: 2px solid #5C84DC;"/>';

						upda += ' </dd>';
						upda += ' </dl>';
						upda += ' </div>';

						upda += ' <div id="bbsCreated_content">';
						upda += ' <dl>';
						upda += ' <dt>내&nbsp;&nbsp;&nbsp;&nbsp;용 </dt>';
						upda += ' <dd>';
						upda += ' <textarea id="update_board_content" cols="63" rows="10" class="boxTA"style="border: 2px solid #5C84DC;">'
								+ e.board_content + '</textarea>';
						upda += ' </dd>';
						upda += ' </dl>';
						upda += ' </div>';
						upda += ' <div id="bbsCreated_footer">';
						upda += ' <dl>';
						upda += ' <td>';
						upda += ' <dd>';
						upda += ' <div id="button">';
						upda += ' <input type="button" class="btn-sm btn-primary" style="margin-top:5px; margin-right:10px"  id="writeClick" onclick="return updateCom('
								+ e.boardnum + ');" value="수정">';
						upda += ' <input type="button" class="btn-sm btn-primary" style="margin-top:5px; id="cancle" onclick="return relist();" value="작성취소">';
						upda += ' </div>';
						upda += ' </dd>';
						upda += ' </dl>';
						upda += ' </table>';
						upda += ' </div>';
						upda += ' </form>';

						$('#writeForm').html(upda);
						$('#listView').show();
						$('#writeForm').hide();

						/* alert('성공했습니다.');
						$('#listView').show();
						loadList(); */
					},

					error : function() {
						alert('실패');
					}

				});

	}

	function updateCom(boardnum) {
		alert('보드넘?' + boardnum)
		var content = $('#update_board_content').val();
		var booknum = window.location.search;
		var book_num = booknum.slice(10, 11);

		$.ajax({
			url : 'updateB',
			type : 'POST',
			data : {
				book_num : book_num,
				boardnum : boardnum,
				content : content
			},
			success : function() {
				alert('성공했습니다.');
				$('#listView').show();
				loadList();
			},
			error : function() {
				alert('실패');
			}

		});
	}

	//탈퇴
	$("#withdrawalForm").on('show.bs.modal', function(event) {
		var button = $(event.relatedTarget)
		var modal = $(this)
		modal.find('.modal-body input').val(recipient)
	})
</script>


</head>
<body style="">
	<!-- 탈퇴 modal -->
	<div class="modal fade" id="withdrawalForm" tabindex="-1" role="dialog"
		aria-labelledby="exampleModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<br> <br> <br> <br> <br> <br>
				<div class="modal-header">
					<form method="post" action="">
						<button type="button" class="close" data-dismiss="modal"
							aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
						<h6 class="modal-title">탈퇴하시겠습니까?</h6>
						<input type="text" class="form-control" id="memo-title"
							name="book_name" placeholder="이름을 입력하세요."> <input
							type="button" class="btn btn-primary-outline btn-shadow"
							data-dismiss="modal" value="취소"> <input type="submit"
							class="btn btn-primary btn-shadow" id="writeMemo" value="확인">
					</form>
				</div>
			</div>
		</div>
	</div>
	<!-- modal 끝 -->
	<div class="page">
		<%@include file="../modules/header.jsp"%>
		<main class="page-content">

		<section style="background-image: url(images/1920x900.jpg);"
			class="section-30 section-sm-40 section-md-66 section-lg-bottom-90 bg-gray-dark page-title-wrap">
			<div class="shell">
				<div class="page-title">
					<h2>Tabs</h2>
				</div>
			</div>
		</section>
		<section
			class="section-bottom-30 section-top-60 section-sm-bottom-40 section-sm-top-90">
			<div class="shell">
				<div class="range range-sm-center">
					<div class="cell-xs-12 text-center">
						<h3>뭔가 제목 입력 안하면 지우기</h3>
					</div>
					<div class="cell-lg-10 offset-top-40">
						<div id="tabs-1"
							class="tabs-custom tabs-horizontal tabs-corporate">
							<ul class="nav nav-tabs">
								<li class="active"><a href="#tabs-1-1" data-toggle="tab">명함첩</a></li>
								<li><a id="tab2" href="#tabs-1-2" data-toggle="tab">게시판</a></li>
								<li><a id="tab3" href="#tabs-1-3" data-toggle="tab">초대하기</a></li>
								<li><a id="tab4" href="#tabs-1-4" data-toggle="tab">구성원</a></li>
								<li><a href="#tabs-1-5" data-toggle="tab">Tab 5</a></li>
							</ul>
							<div class="tab-content text-secondary">
								<div id="tabs-1-1" class="tab-pane fade in active">
									<img src="images/370x278.jpg" alt="" width="400" height="200" />
								</div>
								<div id="tabs-1-2" class="tab-pane fade">

									<div id="listView">

										<table width="100%" cellpadding="0" cellspacing="0" border="0">
											<tr height="5">
												<td width="5"></td>
											</tr>
											<tr
												style="background: url('images/table_mid.gif') repeat-x; text-align: center;">
												<td width="7"><img src="images/table_left.gif"
													width="5" height="30" /></td>
												<td width="73">번호</td>
												<td width="379">제목</td>
												<td width="73">작성자</td>
												<td width="164">작성일</td>
												<td width="58">조회수</td>
												<td width="7"><img src="images/table_right.gif"
													width="5" height="30" /></td>
											</tr>
											<table width="100%" cellpadding="0" cellspacing="0"
												border="0">
												<tr height="5">
													<td width="5"></td>
												</tr>
												<tr style="text-align: center;">
													<td><div id="dataCol"></div></td>
												<tr height="5">
													<td width="5"></td>
												</tr>

											</table>

											<table width="100%" cellpadding="0" cellspacing="0"
												border="0">
												<tr height="1" bgcolor="#5C84DC">
													<td colspan="6" width="752"></td>
												</tr>
											</table>

										</table>

										<table width="100%" cellpadding="0" cellspacing="0" border="0">
											<tr>
												<td colspan="10" height="5"></td>
											</tr>
											<tr align="center">
												<!--   <td><button class="btn btn-primary-outline btn-shadow" id="write"
														onclick="check();">글쓰기</button></td> -->
												<td><input type="button" class="btn-sm btn-primary"
													id="write" onclick="check();" value="글쓰기"></td>
											</tr>
										</table>
									</div>

									<!-- 음...글정보 보는 리스트랑 글쓰기 페이지 보여질떄 쓰이는 div영역 -->
									<div id="writeForm"></div>
									<div id="readData"></div>
									<div id="updateForm"></div>
									<!-- ↑여기까지 -->
								</div>
								<div id="tabs-1-3" class="tab-pane fade">
									<form id="inviteForm" action="inviteList" method="get">
										<select name="searchTitle" id="searchTitle">
											<option value="m_id">아이디로 검색하기</option>
											<option value="m_name">이름으로 검색하기</option>
										</select> <input type="text" id="searchText" value="${searchText}">
										<input type="button" value="검색" id="searchInvite">
									</form>
									<div id="inviteListResult"></div>

								</div>
								<div id="tabs-1-4" class="tab-pane fade">
									<div id="memberList"></div>
								</div>
								<div id="tabs-1-5" class="tab-pane fade">
									<button type="button" class="withdrawalbutton"
										style="vertical-align: middle" data-toggle="modal"
										data-target="#withdrawalForm" data-whatever="@mdo"
										id="showShareRoom">
										<span>탈퇴하기</span>
									</button>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

		</section>

		</main>

		<%@include file="../modules/footer.jsp"%>
		<script src="js/core.min.js"></script>
		<script src="js/script.js"></script>
</body>
</html>