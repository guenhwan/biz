package global.scit.bizcard.controller;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.apache.ibatis.javassist.expr.NewArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.servlet.view.RedirectView;

import global.scit.bizcard.repository.SharingRepository;
import global.scit.bizcard.vo.CardBooks;
import global.scit.bizcard.vo.CardImage;
import global.scit.bizcard.vo.Member;
import global.scit.bizcard.vo.Message;

@Controller
public class SharingController {

	@Autowired
	SharingRepository SharingRepository;

	/**
	 * [현택] 명함 공유 시 공유방 목록 호출
	 * 
	 * @param session
	 * @param model
	 * @param cardnum
	 */
	@ResponseBody
	@RequestMapping(value = "/showShareRoom", method = RequestMethod.GET)
	public ArrayList<HashMap<String, Object>> showShareRoom(HttpSession session) {
		String m_id = (String) session.getAttribute("m_id");
		ArrayList<HashMap<String, Object>> bookList = new ArrayList<HashMap<String, Object>>();
		// 공유방 전체 목록 호출
		bookList = SharingRepository.listCardBooks(m_id);
		System.out.println("코카콜라" + bookList.toString());
		return bookList;
	}

	// 1. 공유방 목록보기
	@RequestMapping(value = "/sharingRoom", method = RequestMethod.GET)
	public String sharedCardsList(Model model, HttpSession session) {
		String m_id = (String) session.getAttribute("m_id");
		ArrayList<HashMap<String, Object>> bookList = new ArrayList<HashMap<String, Object>>();
		bookList = SharingRepository.listCardBooks(m_id);
		model.addAttribute("bookList", bookList);
		System.out.println("yahoo" + bookList.toString());
		return "sharingCards/sharingRoom";
	}

	// 2. 공유방 만들기
	@RequestMapping(value = "/makeRoom", method = RequestMethod.POST)
	public String makeRoom(HttpSession session, CardBooks card) {
		String m_id = (String) session.getAttribute("m_id");
		card.setM_id(m_id);
		card.setGrade("manager");
		SharingRepository.makeRoom(card);
		int CurrentBook_num = SharingRepository.getBookNum(card);
		card.setBook_num(CurrentBook_num);
		SharingRepository.insertManager(card);
		return "redirect:/sharingRoom";
	}

	// 3. 공유방 하나 클릭
	@RequestMapping(value = "/selectOneRoom", method = RequestMethod.GET)
	public String selectOneRoom(int book_num, String book_name, Model model) {
		System.out.println("삭제후: " + book_name);
		List<HashMap<String, Object>> roomList = SharingRepository.selectOneRoom(book_num);
		model.addAttribute("book_num", book_num);
		model.addAttribute("book_name", book_name);
		model.addAttribute("roomList", roomList);
		String book_master = (String) roomList.get(0).get("BOOK_MASTER");
		model.addAttribute("book_master", book_master);
		return "sharingCards/selectOneRoom";
	}

	// 초대할 목록 보여주기
	@ResponseBody
	@RequestMapping(value = "/inviteList", method = RequestMethod.GET)
	public ArrayList<Member> inviteList(HttpSession session, Model model,
			@RequestParam(value = "searchTitle", defaultValue = "") String searchTitle,
			@RequestParam(value = "searchText", defaultValue = "") String searchText) {
		ArrayList<Member> iList = SharingRepository.inviteList(searchTitle, searchText);
		for (int i = 0; i < iList.size(); i++) {
			if (iList.get(i).getM_id().equals(session.getAttribute("m_id"))) {
				iList.remove(i);
			}
		}
		model.addAttribute("searchTitle", searchTitle);
		model.addAttribute("searchTitle", searchText);
		model.addAttribute("iList", iList);

		return iList;
	}

	// 초대장 폼
	@RequestMapping(value = "/invitationCard", method = RequestMethod.GET)
	public String invitationCard(String targetId, int book_num, Model model) {
		model.addAttribute("targetId", targetId);
		model.addAttribute("book_num", book_num);
		return "sharingCards/invitationCard";
	}

	// 초대장 보내기
	@RequestMapping(value = "/invite", method = RequestMethod.POST)
	public String invite(Message message, HttpSession session) {
		String m_id = (String) session.getAttribute("m_id");
		message.setTargetId(message.getTargetId()); // 메시지 받는 사람 set
		message.setSender(m_id); // 메시지 보내는 사람 set
		message.setType("invitation"); // 메시지 타입을 초대장으로 set
		message.setBook_num(message.getBook_num()); // 방 번호 set 하기
		System.out.println("초대장보내기" + message.toString());
		SharingRepository.invite(message);

		return null;
	}

	// 공유방 구성원 보기
	@ResponseBody
	@RequestMapping(value = "/allMember", method = RequestMethod.GET)
	public List<HashMap<String, Object>> allMember(int book_num, Model model) {
		List<HashMap<String, Object>> roomList;
		roomList = SharingRepository.allMember(book_num);
		System.out.println("구성원보기" + roomList.toString());
		model.addAttribute("roomList", roomList);
		return roomList;
	}

	// 초대 수락하기
	@RequestMapping(value = "/joinRoom", method = RequestMethod.POST)
	public String joinRoom(int book_num, HttpSession session) {
		System.out.println("초대수락하기");
		System.out.println("수락: " + book_num);
		String m_id = (String) session.getAttribute("m_id");
		CardBooks card = new CardBooks();
		card.setBook_num(book_num);
		card.setM_id(m_id);
		card.setGrade("member");
		System.out.println(card.toString() + "초대수락");
		SharingRepository.joinRoom(card);

		return null;
	}

	// 탈퇴 하기 기능
	@RequestMapping(value = "/leaveRoom", method = RequestMethod.POST)
	public String withdrawal(CardBooks card, HttpSession session) {
		System.out.println("leaveRoom: " + card.toString());
		String m_id = (String) session.getAttribute("m_id");
		// 1.book_master가 탈퇴할 경우
		if (card.getBook_master().equals(m_id)) {
			// 1-a. 공유된 명함 삭제
			SharingRepository.sharedCardDeleteByBook_Master(card);

			// 1-b. 멤버 삭제
			SharingRepository.leaveRoom(card);

			// 1-c. 공유방 삭제
			SharingRepository.cardBooksDelete(card);

			
		} else {
			// 2. 일반 멤버가 탈퇴할 경우
			card.setM_id(m_id);
			SharingRepository.leaveRoom(card);
		}

		return "redirect:sharingRoom";
	}

	// 근환이형 이미지 공유하기
	@ResponseBody
	@RequestMapping(value = "/getRoomCard", method = RequestMethod.POST)
	public ArrayList<CardImage> roomCard(int book_num, HttpSession session) {
		ArrayList<CardImage> cardList = (ArrayList<CardImage>) SharingRepository.getRoomCards(book_num);
		System.out.println("공유방의카드: " + cardList.toString());
		if (cardList != null) {
			return cardList;
		}
		return null;
	}

	// 댓글방에서 공유된 명함 삭제
	@RequestMapping(value = "/sharedCardDelete", method = RequestMethod.POST)
	public String sharedCardDelete(String sharedId, int shared_cardnum, int book_num, String book_name,
			HttpSession session, RedirectAttributes attributes) {

		String loginId = (String) session.getAttribute("m_id");
		if (loginId.equals(sharedId)) {
			SharingRepository.sharedCardDelete(shared_cardnum);
			try {
				book_name = URLEncoder.encode(book_name, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			}
			return "redirect:selectOneRoom?book_num=" + book_num + "&book_name=" + book_name;
		}
		return null;
	}

	/*
	 * 아래 부터는 쪽지 기능 * * * * * * * * * * * * * *
	 */
	@RequestMapping(value = "/messageList", method = RequestMethod.GET)
	public String messageList(HttpSession session, Model model) {
		ArrayList<Message> inbox = new ArrayList<>();
		String m_id = (String) session.getAttribute("m_id");
		ArrayList<Message> messageList = SharingRepository.messageList(m_id);
		for (Message message : messageList) {
			if (message.getTargetId().equals(m_id)) {
				inbox.add(message);
				model.addAttribute("inbox", inbox);
			}
		}
		return "sharingCards/messageList";
	}

	// 수신함(inbox) 요청
	@ResponseBody
	@RequestMapping(value = "/inBoxList", method = RequestMethod.GET)
	public ArrayList<Message> inBoxList(HttpSession session, Model model) {
		ArrayList<Message> inbox = new ArrayList<>();
		String m_id = (String) session.getAttribute("m_id");
		ArrayList<Message> messageList = SharingRepository.messageList(m_id);
		for (Message message : messageList) {
			if (message.getTargetId().equals(m_id)) {
				inbox.add(message);
			}
		}
		return inbox;
	}

	// 발신함(outbox) 요청
	@ResponseBody
	@RequestMapping(value = "/outBoxList", method = RequestMethod.GET)
	public ArrayList<Message> outBoxList(HttpSession session) {
		ArrayList<Message> outbox = new ArrayList<>();
		String m_id = (String) session.getAttribute("m_id");
		ArrayList<Message> messageList = SharingRepository.messageList(m_id);
		for (Message message : messageList) {
			if (message.getSender().equals(m_id)) {
				outbox.add(message);
			}
		}
		return outbox;
	}

	// 메시지 보내기
	@RequestMapping(value = "/writeMessage", method = RequestMethod.POST)
	public String writeMessage(Message message, HttpSession session) {
		String m_id = (String) session.getAttribute("m_id");
		message.setSender(m_id);
		message.setType("message");
		message.setBook_num(0000); // 일반 메시지의 경우 0000을 임의로 set한다.
		SharingRepository.writeMessage(message);
		return "redirect:/messageList";
	}

	// 메시지 하나 클릭 시
	@RequestMapping(value = "/invitedCard", method = RequestMethod.GET)
	public String invitedCard(@RequestParam(value = "book_num", defaultValue = "0") int book_num,
			@RequestParam(value = "sender") String sender, @RequestParam(value = "message") String message,
			@RequestParam(value = "date") String date,Model model) {

		/*
		 * if(book_num!=0){ String book_name =
		 * SharingRepository.getBookName(book_num);
		 * model.addAttribute("book_name", book_name); }
		 */
		String bookName=SharingRepository.getBookName(book_num);
		model.addAttribute("bookName",bookName);
		model.addAttribute("m_book_num", book_num);
		
		model.addAttribute("m_sender", sender);
		model.addAttribute("m_message", message);
		model.addAttribute("m_date", date);
		Message m = new Message();
		m.setSenddate(date);
		m.setBook_num(book_num);
		m.setSender(sender);
		m.setMessage(message);
		SharingRepository.readMessage(m);
		
		
		
		
		return "sharingCards/invitedCard";
	}

	// 메시지 삭제
	@ResponseBody
	@RequestMapping(value = "/delMessage", method = RequestMethod.POST)
	public int delMessage(String delSender, String delMessage, HttpSession session) {
		String loginId = (String) session.getAttribute("m_id");
		Message message = new Message();
		message.setSender(delSender);
		message.setMessage(delMessage);
		message.setTargetId(loginId);
		return SharingRepository.delMessage(message);
	}

	// 테스트 페이지 입니다.
	@RequestMapping(value = "/test", method = RequestMethod.GET)
	public String test() {
		return "sharingCards/test";
	}

}