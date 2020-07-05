import React from 'react'
import ReactDOM from 'react-dom'
import { BoardForm } from './BoardForm'
import { boards } from './routes'
import { railsApi } from './runtime'

const NewBoard = () => {
  const handleSubmit = (values) => {
    const result = railsApi('POST', boards, values)
    return result.then(({ json }) => {
      if (json instanceof Array) {
        return Promise.reject(json)
      } else {
        window.location.href = json.url
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
