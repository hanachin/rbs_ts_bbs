import React from 'react'
import ReactDOM from 'react-dom'
import { BoardForm } from './BoardForm'
import { boards } from './rbs_ts_routes'
import { railsApi } from './rbs_ts_runtime'

const NewBoard = () => {
  const handleSubmit = (values) => {
    const result = railsApi('POST' as const, boards, values)
    return result.then(({ json }) => {
      if (json instanceof Array) {
        return Promise.reject(json)
      } else {
        window.location.href = boards.path({})
        return Promise.resolve()
      }
    })
  }
  return (
    <>
      <h1>New Board</h1>
      <BoardForm title={''} submit={'Create Board'} onSubmit={handleSubmit} />
      <a href={boards.path({})}>Back</a>
    </>
  )
}

document.addEventListener('turbolinks:load', () => {
  const element = document.getElementById('new-board')

  if (!element) return

  ReactDOM.render(
    <NewBoard />,
    element,
  )
})
