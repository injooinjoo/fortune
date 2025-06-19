'use client'

import React, { useState } from 'react'
import Link from 'next/link'
import {
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
} from '@/components/ui/tabs'
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from '@/components/ui/select'
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group'
import { Label } from '@/components/ui/label'
import { ChartContainer } from '@/components/ui/chart'

interface HistoryItem {
  id: number
  date: string
  type: string
  summary: string
  link: string
}

const historyMock: HistoryItem[] = [
  {
    id: 1,
    date: '2024-06-01',
    type: '오늘의 총운',
    summary: '85점 - 매우 좋음',
    link: '/fortune/daily?date=2024-06-01',
  },
  {
    id: 2,
    date: '2024-05-31',
    type: '사주팔자',
    summary: '78점 - 좋음',
    link: '/fortune/saju?date=2024-05-31',
  },
  {
    id: 3,
    date: '2024-05-30',
    type: 'MBTI 운세',
    summary: '70점 - 보통',
    link: '/fortune/mbti?date=2024-05-30',
  },
  {
    id: 4,
    date: '2024-05-29',
    type: '오늘의 총운',
    summary: '90점 - 최고',
    link: '/fortune/daily?date=2024-05-29',
  },
]

const scoreTrendMock = [
  { date: '2024-05-01', score: 70 },
  { date: '2024-05-10', score: 80 },
  { date: '2024-05-20', score: 75 },
  { date: '2024-05-30', score: 85 },
]

const categoryMock = [
  { name: '오늘의 총운', value: 40 },
  { name: '사주팔자', value: 30 },
  { name: 'MBTI 운세', value: 30 },
]

export default function HistoryPage() {
  const [typeFilter, setTypeFilter] = useState('all')
  const [dateFilter, setDateFilter] = useState('all')

  const filtered = historyMock.filter((item) => {
    const matchType = typeFilter === 'all' || item.type === typeFilter
    let matchDate = true
    if (dateFilter !== 'all') {
      const today = new Date('2024-06-01')
      const itemDate = new Date(item.date)
      const diffDays = (today.getTime() - itemDate.getTime()) / (1000 * 60 * 60 * 24)
      if (dateFilter === '7') {
        matchDate = diffDays <= 7
      } else if (dateFilter === '30') {
        matchDate = diffDays <= 30
      }
    }
    return matchType && matchDate
  })

  return (
    <div className="p-4 space-y-4">
      <Tabs defaultValue="recent" className="w-full">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="recent">최근 기록</TabsTrigger>
          <TabsTrigger value="stats">통계 분석</TabsTrigger>
        </TabsList>
        <TabsContent value="recent" className="space-y-4">
          <div className="flex space-x-2">
            <Select onValueChange={setDateFilter} defaultValue="all">
              <SelectTrigger className="w-32">
                <SelectValue placeholder="기간" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">전체</SelectItem>
                <SelectItem value="7">최근 7일</SelectItem>
                <SelectItem value="30">최근 1개월</SelectItem>
              </SelectContent>
            </Select>
            <Select onValueChange={setTypeFilter} defaultValue="all">
              <SelectTrigger className="w-36">
                <SelectValue placeholder="종류" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">전체</SelectItem>
                <SelectItem value="오늘의 총운">오늘의 총운</SelectItem>
                <SelectItem value="사주팔자">사주팔자</SelectItem>
                <SelectItem value="MBTI 운세">MBTI 운세</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <ul className="space-y-2">
            {filtered.map((item) => (
              <li key={item.id} className="border rounded-md p-3 hover:bg-muted">
                <Link href={item.link} className="block">
                  <div className="flex justify-between text-sm">
                    <span className="font-medium">{item.date}</span>
                    <span className="text-muted-foreground">{item.type}</span>
                  </div>
                  <p className="text-sm mt-1">{item.summary}</p>
                </Link>
              </li>
            ))}
          </ul>
        </TabsContent>
        <TabsContent value="stats" className="space-y-6">
          <div className="space-y-2">
            <RadioGroup defaultValue="monthly" className="flex space-x-4">
              <div className="flex items-center space-x-1">
                <RadioGroupItem value="weekly" id="weekly" />
                <Label htmlFor="weekly">주간</Label>
              </div>
              <div className="flex items-center space-x-1">
                <RadioGroupItem value="monthly" id="monthly" />
                <Label htmlFor="monthly">월간</Label>
              </div>
            </RadioGroup>
            <h3 className="font-semibold text-lg">지난 한 달간의 운세 점수 변화</h3>
            <ChartContainer config={{ score: { color: '#8884d8' } }}>
              {/* TODO: line chart */}
            </ChartContainer>
          </div>
          <div className="space-y-2">
            <h3 className="font-semibold text-lg">가장 많이 본 운세</h3>
            <ChartContainer config={{}}>{/* TODO: pie chart */}</ChartContainer>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}
