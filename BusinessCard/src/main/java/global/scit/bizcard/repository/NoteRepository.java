package global.scit.bizcard.repository;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import global.scit.bizcard.dao.NoteDAO;
import global.scit.bizcard.vo.CardImage;
import global.scit.bizcard.vo.Note;

@Repository
public class NoteRepository {

	@Autowired
	SqlSession sqlSession;
	
	public List<Note> noteList(String m_id) {
		System.out.println(m_id);
		NoteDAO dao = sqlSession.getMapper(NoteDAO.class);
		List<Note> list = null;
		try {
			list = dao.noteList(m_id);
			System.out.println(list.toString()+"레퍼지토리");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}
	
	public int addNote(Note note) {
		NoteDAO dao = sqlSession.getMapper(NoteDAO.class);
		int result =0;
		try {
			result = dao.addNote(note);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	public int addYourNote(Note note) {
		NoteDAO dao = sqlSession.getMapper(NoteDAO.class);
		int result =0;
		try {
			result = dao.addYourNote(note);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	public int deleteNote(Note note) {
		NoteDAO dao = sqlSession.getMapper(NoteDAO.class);
		int result = 0;
		try {
			result = dao.deleteNote(note);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return result;
	}
	
	public int deleteYourNote(int cardnum) {
		NoteDAO dao = sqlSession.getMapper(NoteDAO.class);
		int result = 0;
			try {
				result = dao.deleteYourNote(cardnum);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		return result;
	}
}
