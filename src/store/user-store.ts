import { create } from 'zustand'

interface UserState {
  name: string
  mbti: string
  setUser: (name: string, mbti: string) => void
}

const useUserStore = create<UserState>((set) => ({
  name: '',
  mbti: '',
  setUser: (name, mbti) => set({ name, mbti }),
}))

export default useUserStore
