import React, { useState } from 'react'
import {
  pluralize,
  label,
  textField,
  submit
} from './helpers'

export const BoardForm: React.FC<{ title: string, submit: string, onSubmit: (values: { title: string }) => Promise<any> }> = ({ title, submit: submitValue, onSubmit }) => {
  const [errorMessages, setErrorMessages] = useState<string[]>([])
  const [loading, setLoading] = useState<boolean>(false)
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    setLoading(true)
    e.preventDefault()
    const form = e.currentTarget
    const formData = new FormData(form)
    const title = formData.get('title')
    if (typeof title === 'string') {
      onSubmit({ title }).catch(messages => {
        setErrorMessages(messages)
      }).finally(() => setLoading(false))
    }
  }
  return (
    <form onSubmit={handleSubmit}>
      {errorMessages.length !== 0 && (
        <div id="error_explanation">
          <h2>{pluralize(errorMessages.length, "error")} prohibited this board from being saved:</h2>

          <ul>
            {errorMessages.map((message, index) => <li key={index}>{message}</li>)}
          </ul>
        </div>
      )}

      <div className="field">
        {label('title')}
        {textField('title', title)}
      </div>

      <div className="actions">
        {submit({ disabled: loading, value: submitValue })}
      </div>
    </form>
  )
}
